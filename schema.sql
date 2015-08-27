DROP TABLE IF EXISTS beers, reviews;

CREATE TABLE beers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);

CREATE INDEX beers_name ON beers(name);

CREATE TABLE reviews (
  id SERIAL PRIMARY KEY,
  body VARCHAR(255) NOT NULL,
  beer_id INTEGER NOT NULL REFERENCES beers
);

INSERT INTO beers (name) VALUES ('Natural Ice');
INSERT INTO beers (name) VALUES ('Natural Light');
INSERT INTO reviews (body, beer_id) VALUES ('Brings me back', 1);
INSERT INTO reviews (body, beer_id) VALUES ('The worst', 2);
