--
-- PostgreSQL database dump
--

-- SET statement_timeout = 0;
-- SET lock_timeout = 0;
-- SET client_encoding = 'UTF8';
-- SET standard_conforming_strings = on;
-- SET check_function_bodies = false;
-- SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

-- CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

-- COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


-- SET search_path = public, pg_catalog;

-- SET default_tablespace = '';

-- SET default_with_oids = false;

PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id integer PRIMARY KEY
  , fname character varying
  , lname character varying
);

CREATE TABLE questions (
  id integer PRIMARY KEY
  , title character varying
  , body character varying
  , author_id integer NOT NULL
  , FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_follows(
  id integer PRIMARY KEY
  , question_id integer NOT NULL
  , user_id integer NOT NULL
  , FOREIGN KEY (question_id) REFERENCES questions(id)
  , FOREIGN KEY (user_id) REFERENCES users(id) 
);

CREATE TABLE replies(
  id integer PRIMARY KEY
  , question_id integer NOT NULL
  , reply_id integer 
  , user_id integer NOT NULL
  , body character varying
  , FOREIGN KEY (question_id) REFERENCES questions(id)
  , FOREIGN KEY (user_id) REFERENCES users(id)
  , FOREIGN KEY (reply_id) REFERENCES replies(id)
);

CREATE TABLE question_likes(
  id integer PRIMARY KEY
  , question_id integer NOT NULL
  , user_id integer
  , FOREIGN KEY (question_id) REFERENCES questions(id)
  , FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO users (fname, lname)
VALUES ('sam', 'hecht')
, ('poorva', 'shelke')
, ('winnie the', 'pooh')
, ('eeyore', 'the sad donkey')
, ('mickey', 'mouse')
;
INSERT INTO questions (title, body, author_id)
VALUES ('the BIBLE', 'god is vengeful...god is a hippie', 1)
  , ('PS I LOVE YOU', 'ew..sad. cry cry cry romance',2)
  ;
INSERT INTO question_follows (question_id, user_id)
VALUES (1, 1)
,(2, 2)
,(2, 3)
,(2, 4)
;
INSERT INTO replies (question_id, reply_id, user_id, body)
  VALUES (1, NULL, 2, 'what is going on here')
  , (1,1,1, 'i have no idea man')
  ;
INSERT INTO question_likes (question_id, user_id)
VALUES (1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(2,1),
(2,2)
;

