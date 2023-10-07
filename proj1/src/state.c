#include "state.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_state_t* state, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_state_t* state, unsigned int snum);
static char next_square(game_state_t* state, unsigned int snum);
static void update_tail(game_state_t* state, unsigned int snum);
static void update_head(game_state_t* state, unsigned int snum);

/* Task 1 */
game_state_t* create_default_state() {
    size_t num_rows = 18;
    game_state_t* def_state = malloc(sizeof(game_state_t));
    def_state->num_rows = 18;
    def_state->num_snakes = 1;
    char** default_board = malloc(num_rows * sizeof(char*));
    for (int i = 0; i < num_rows; i++) {
        default_board[i] = (char*)malloc(21 * sizeof(char));
    }
    char up_bound[] = "####################";
    char mid[] = "#                  #";

    strcpy(default_board[0], up_bound);
    strcpy(default_board[num_rows - 1], up_bound);

    for (int i = 1; i < num_rows - 1; ++i) {
        strcpy(default_board[i], mid);
    }
    def_state->board = default_board;

    snake_t* default_snake = malloc(def_state->num_snakes * sizeof(snake_t));
    default_snake[0].tail_row = 2;
    default_snake[0].tail_col = 2;
    default_snake[0].head_row = 2;
    default_snake[0].head_col = 4;
    default_snake[0].live = true;

    def_state->snakes = default_snake;

    set_board_at(def_state, default_snake[0].tail_row, default_snake[0].tail_col, 'd');
    set_board_at(def_state, 2, 3, '>');
    set_board_at(def_state, default_snake[0].head_row, default_snake[0].head_col, 'D');
    set_board_at(def_state, 2, 9, '*');

    return def_state;
}

/* Task 2 */
void free_state(game_state_t* state) {
    char** board = state->board;
    for (int i = 0; i < state->num_rows; ++i) {
        free(*(board + i));
    }
    free(state->board);
    free(state->snakes);
    free(state);
    return;
}

/* Task 3 */
void print_board(game_state_t* state, FILE* fp) {
    char** board = state->board;
    for (int i = 0; i < state->num_rows; ++i) {
        fprintf(fp, "%s\n", board[i]);
    }

    return;
}

/*
  Saves the current state into filename. Does not modify the state object.
  (already implemented for you).
*/
void save_board(game_state_t* state, char* filename) {
    FILE* f = fopen(filename, "w");
    print_board(state, f);
    fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_state_t* state, unsigned int row, unsigned int col) {
    return state->board[row][col];
}

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_state_t* state, unsigned int row, unsigned int col, char ch) {
    state->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
    if (c == 'w' || c == 'a' || c == 's' || c == 'd') {
        return true;
    }
    return false;
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
    if (c == 'W' || c == 'A' || c == 'S' || c == 'D') {
        return true;
    }
    return false;
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
    if (is_head(c) || is_tail(c) || c == '^' || c == '>' || c == 'v' || c == '<') {
        return true;
    }
    return false;
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
    if (c == '<' || c == '>' || c == '^' || c == 'v') {
        char body[4] = {'^', '<', 'v', '>'};
        char tail[4] = {'w', 'a', 's', 'd'};
        int index = 0;
        while (index < 4) {
            if (body[index] == c)
                break;
            index++;
        }
        return tail[index];
    }
    return '?';
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
    if (c != 'x' && is_head(c)) {
        char body[4] = {'^', '<', 'v', '>'};
        char head[4] = {'W', 'A', 'S', 'D'};
        int index = 0;
        while (index < 4) {
            if (head[index] == c)
                break;
            index += 1;
        }
        return body[index];
    }
    return '?';
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
    if (c == 'v' || c == 's' || c == 'S') {
        return cur_row + 1;
    } else if (c == '^' || c == 'w' || c == 'W') {
        return cur_row - 1;
    }
    return cur_row;
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
    if (c == '>' || c == 'd' || c == 'D') {
        return cur_col + 1;
    } else if (c == '<' || c == 'a' || c == 'A') {
        return cur_col - 1;
    }
    return cur_col;
}

/*
  Task 4.2

  Helper function for update_state. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_state_t* state, unsigned int snum) {
    snake_t* snake = state->snakes;
    char head = state->board[snake[snum].head_row][snake[snum].head_col];
    return state->board[get_next_row(snake[snum].head_row, head)][get_next_col(snake[snum].head_col, head)];
}

/*
  Task 4.3

  Helper function for update_state. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_state_t* state, unsigned int snum) {
    snake_t* snake = state->snakes;
    // get original had character,ie., D
    char head = state->board[snake[snum].head_row][snake[snum].head_col];
    // change next block head would move next to original head.
    unsigned int row = get_next_row(snake[snum].head_row, head);
    unsigned int col = get_next_col(snake[snum].head_col, head);
    state->board[row][col] = head;
    // change original head's block to body character.
    state->board[snake[snum].head_row][snake[snum].head_col] = head_to_body(head);
    // change snake's head index.
    snake[snum].head_row = row;
    snake[snum].head_col = col;
    return;
}

/*
  Task 4.4

  Helper function for update_state. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_state_t* state, unsigned int snum) {
    snake_t* snake = state->snakes;
    char tail = state->board[snake[snum].tail_row][snake[snum].tail_col];
    unsigned int row = get_next_row(snake[snum].tail_row, tail);
    unsigned int col = get_next_col(snake[snum].tail_col, tail);
    state->board[row][col] = body_to_tail(state->board[row][col]);
    state->board[snake[snum].tail_row][snake[snum].tail_col] = ' ';
    snake[snum].tail_row = row;
    snake[snum].tail_col = col;
    return;
}

/* Task 4.5 */
void update_state(game_state_t* state, int (*add_food)(game_state_t* state)) {
    unsigned int cnt = state->num_snakes;
    snake_t* snake = state->snakes;
    for (int i = 0; i < cnt; i++) {
        unsigned int row = snake[i].head_row;
        unsigned int col = snake[i].head_col;
        char nxt = next_square(state, i);
        if (nxt == '#' || is_snake(nxt)) {
            state->board[row][col] = 'x';
            snake[i].live = false;
            continue;
        } else {
            update_head(state, i);
            if (nxt != '*') {
                update_tail(state, i);
            } else {
                add_food(state);
            }
        }
    }
}

int* get_file_shape(FILE* file) {
    int* shape = malloc(sizeof(int) * 2);
    shape[0] = 0;
    shape[1] = 0;
    int temp = 0;
    char c = fgetc(file);
    while (c != EOF) {
        if (c == '\n') {
            shape[0]++;
            shape[1] = temp > shape[1] ? temp : shape[1];
            temp = 0;
        } else {
            temp++;
        }
        c = fgetc(file);
    }
    fseek(file, 0, SEEK_SET);
    shape[1] = shape[1] + 1;
    return shape;
}

/* Task 5 */
game_state_t* load_board(FILE* fp) {
    game_state_t* state = malloc(sizeof(game_state_t));
    int* shape = get_file_shape(fp);
    char** board = malloc(sizeof(char*) * shape[0]);
    state->num_rows = shape[0];

    for (size_t i = 0; i < shape[0]; i++) {
        board[i] = malloc(sizeof(char) * shape[1]);
    }

    char c = fgetc(fp);
    int i = 0, j = 0;
    while (c != EOF) {
        if (c == '\n') {
            board[i][j] = '\0';
            i++;
            j = 0;
        } else {
            board[i][j] = c;
            j++;
        }
        c = fgetc(fp);
    }

    free(shape);
    state->board = board;
    state->num_snakes = 0;
    state->snakes = NULL;

    return state;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_state_t* state, unsigned int snum) {
    char** board = state->board;
    snake_t* snake = state->snakes;
    snake[snum].tail_row = 0;
    snake[snum].tail_col = 0;
    for (int i = 0, j = 0; i < state->num_rows; j++) {
        if (board[i][j] == '\0') {
            i++;
            j = 0;
            continue;
        } else if (is_tail(board[i][j])) {

            int flag = 1;
            for (int k = 0; k < state->num_snakes; k++) {
                if (snake[k].tail_row == i && snake[k].tail_col == j) {
                    flag = 0;
                    break;
                }
            }
            if (flag) {
                int pre[] = {i, j};
                int nxt[] = {-1, -1};
                nxt[0] = get_next_row(pre[0], board[pre[0]][pre[1]]);
                nxt[1] = get_next_col(pre[1], board[pre[0]][pre[1]]);
                while (!is_head(board[nxt[0]][nxt[1]])) {
                    pre[0] = nxt[0];
                    pre[1] = nxt[1];
                    nxt[0] = get_next_row(pre[0], board[pre[0]][pre[1]]);
                    nxt[1] = get_next_col(pre[1], board[pre[0]][pre[1]]);
                }
                snake[snum].tail_row = i;
                snake[snum].tail_col = j;
                snake[snum].head_row = nxt[0];
                snake[snum].head_col = nxt[1];
                return;
            }
        }
    }
    return;
}

/* Task 6.2 */
game_state_t* initialize_snakes(game_state_t* state) {
    int idx = 0;
    int num = 1;
    snake_t* snake = malloc(sizeof(snake_t) * num);
    state->snakes = snake;
    while (true) {
        if (idx >= num) {
            num *= 2;
            snake = realloc(snake, sizeof(snake_t) * num);
            state->snakes = snake;
        }
        
        snake[idx].tail_row = 0;
        snake[idx].tail_col = 0;
        snake[idx].live = true;
        find_head(state, idx);

        if (snake[idx].tail_row != 0) {
            state->num_snakes++;
            idx++;
        } else {
            break;
        }
    }
    if (idx != num){
        snake = realloc(snake, sizeof(snake_t) * idx);
        state->snakes = snake;
        state->num_snakes = idx;
    }
    
    return state;
}
