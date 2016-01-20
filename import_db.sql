DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS questions;
CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;
CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  questions_id INTEGER NOT NULL,
  users_id INTEGER NOT NULL,
  FOREIGN KEY (questions_id) REFERENCES questions(id),
  FOREIGN KEY (users_id) REFERENCES users(id)
);


DROP TABLE IF EXISTS replies;
CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  questions_id INTEGER NOT NULL,
  parent_id INTEGER NULL,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(parent_id)
);


DROP TABLE IF EXISTS question_likes;
CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    upvote INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

-- # Seeding our tables with data
INSERT INTO
  users (fname, lname)
  VALUES
  ('Michael', 'Park'),
  ('Bradley', 'Neal');

INSERT INTO
  questions (title, body, author_id)
  VALUES
  ('w3d2', 'do i need my comp??', (SELECT id FROM users WHERE fname = 'Michael' AND lname = 'Park')),
  ('SQL', 'what are sequelll?', (SELECT id FROM users WHERE fname = 'Bradley' AND lname = 'Neal'));

INSERT INTO
  question_follows (questions_id, users_id)
  VALUES
  (1, 1),
  (2, 2),
  (1, 2);

INSERT INTO
  replies (questions_id, parent_id, user_id, body)
  VALUES
  (1, NULL, 2, "yes you need your computer, you idiot. <3"),
  (2, NULL, 1, "they are a RDBMS language"),
  (1, 1, 1, "thanks a lot <3");

INSERT INTO
question_likes (upvote, question_id, user_id)
VALUES
(1, 1, 2),
(1, 2, 1),
(1, 1, 1);
