-- set up indexes
-- on delete cascade?

CREATE TABLE countries (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(45) NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE media_types (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(45) NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE material_formats (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(45) NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE collections (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(45) NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE catalogers (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(45) NOT NULL,
  email       TEXT        NOT NULL UNIQUE CHECK ((position('@' IN email) > 1)
                                                 AND
                                                 (position('.' IN email) > 0)),
  description TEXT
);

CREATE TABLE works (
  id                 SERIAL PRIMARY KEY,
  title              VARCHAR(100)                         NOT NULL,
  secondary_title    VARCHAR(100),
  year               INTEGER                              NOT NULL -- put in future dates or no?
    CHECK ((year >= 1900) AND
           (year <= EXTRACT(YEAR FROM now()) :: INTEGER)),
  country_id         INTEGER REFERENCES countries (id),
  media_type_id      INTEGER                              NOT NULL REFERENCES media_types (id),
  collection_id      INTEGER REFERENCES collections (id),
  finding_aid_link   TEXT,
  material_format_id INTEGER                              NOT NULL REFERENCES material_formats (id),
  rights_holder      VARCHAR(100),

  -- items below this point formerly captured in CAT_NOTES table
  cataloger_id       INTEGER REFERENCES catalogers (id)   NOT NULL,
  entry_date         TIMESTAMPTZ DEFAULT now()            NOT NULL,
  citation_source    TEXT,
  alias_alternates   TEXT,
  cataloging_notes   TEXT

);

CREATE TABLE repositories (
  id       SERIAL PRIMARY KEY,
  name     VARCHAR(100) NOT NULL,
  location VARCHAR(100) NOT NULL,
  website  TEXT
);

CREATE TABLE composers (
  id        SERIAL PRIMARY KEY,
  name      VARCHAR(100) NOT NULL,
  imdb_link TEXT
);

CREATE TABLE directors (
  id        SERIAL PRIMARY KEY,
  name      VARCHAR(100) NOT NULL,
  imdb_link TEXT
);

CREATE TABLE production_companies (
  id           SERIAL PRIMARY KEY,
  name         VARCHAR(100) NOT NULL,
  contact_info TEXT
);

CREATE TABLE publishers (
  id           SERIAL PRIMARY KEY,
  name         VARCHAR(100) NOT NULL,
  contact_info TEXT
);

CREATE TABLE work_repository (
  id            SERIAL PRIMARY KEY,
  work_id       INTEGER NOT NULL REFERENCES works (id),
  repository_id INTEGER NOT NULL REFERENCES repositories (id),
  UNIQUE (work_id, repository_id)
);

CREATE TABLE work_composer (
  id          SERIAL PRIMARY KEY,
  work_id     INTEGER NOT NULL REFERENCES works (id),
  composer_id INTEGER NOT NULL REFERENCES composers (id),
  UNIQUE (work_id, composer_id)
);

CREATE TABLE work_director (
  id          SERIAL PRIMARY KEY,
  work_id     INTEGER NOT NULL REFERENCES works (id),
  director_id INTEGER NOT NULL REFERENCES directors (id),
  UNIQUE (work_id, director_id)
);

CREATE TABLE work_production_company (
  id                    SERIAL PRIMARY KEY,
  work_id               INTEGER NOT NULL REFERENCES works (id),
  production_company_id INTEGER NOT NULL REFERENCES production_companies (id),
  UNIQUE (work_id, production_company_id)
);

CREATE TABLE work_publisher (
  id           SERIAL PRIMARY KEY,
  work_id      INTEGER NOT NULL REFERENCES works (id),
  publisher_id INTEGER NOT NULL REFERENCES publishers (id),
  UNIQUE (work_id, publisher_id)
);
