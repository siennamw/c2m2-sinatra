CREATE VIEW overview_by_work AS
  SELECT
    works.id                                  AS work_id,
    works.title,
    works.secondary_title,
    countries.name                            AS country,
    string_agg(DISTINCT directors.name, '; ') AS director,
    string_agg(DISTINCT composers.name, '; ') AS composer,
    works.year

  FROM works
    LEFT JOIN countries
      ON works.country_id = countries.id
    LEFT JOIN work_director
      ON work_director.work_id = works.id
    LEFT JOIN directors
      ON work_director.director_id = directors.id
    LEFT JOIN work_composer
      ON works.id = work_composer.work_id
    LEFT JOIN composers
      ON work_composer.composer_id = composers.id
  GROUP BY works.id, works.title, works.secondary_title, countries.name,
    works.year
  ORDER BY works.title;

CREATE VIEW work_details AS
  SELECT
    works.id                                                     AS work_id,
    works.title,
    works.secondary_title,
    string_agg(DISTINCT work_director.director_id :: TEXT,
                        '&&')                                    AS director_ids,
    string_agg(DISTINCT work_composer.composer_id :: TEXT,
                        '&&')                                    AS composer_ids,
    works.year,
    works.finding_aid_link,
    countries.id                                                 AS country_id,
    countries.name                                               AS country,
    media_types.id                                               AS media_type_id,
    media_types.name                                             AS media_type,
    collections.id                                               AS collection_id,
    collections.name                                             AS collection,
    material_formats.id                                          AS material_format_id,
    material_formats.name                                        AS material_format,
    catalogers.id                                                AS cataloger_id,
    catalogers.name                                              AS cataloger
  FROM works
    LEFT JOIN work_director
      ON work_director.work_id = works.id
    LEFT JOIN work_composer
      ON works.id = work_composer.work_id
    LEFT JOIN countries
      ON works.country_id = countries.id
    LEFT JOIN media_types
      ON works.media_type_id = media_types.id
    LEFT JOIN collections
      ON works.collection_id = collections.id
    LEFT JOIN material_formats
      ON works.material_format_id = material_formats.id
    LEFT JOIN catalogers
      ON works.cataloger_id = catalogers.id
  GROUP BY works.id,
    works.title,
    works.secondary_title,
    works.year,
    countries.id,
    countries.name,
    media_types.id,
    media_types.name,
    collections.id,
    collections.name,
    material_formats.id,
    material_formats.name,
    catalogers.id,
    catalogers.name
  ORDER BY works.title;

CREATE VIEW catalog_title_view AS
  SELECT
    works.id              AS work_id,
    works.title,
    works.secondary_title,
    works.finding_aid_link,
    countries.id          AS country_id,
    countries.name        AS country,
    media_types.id        AS media_type_id,
    media_types.name      AS media_type,
    collections.id        AS collection_id,
    collections.name      AS collection,
    material_formats.id   AS material_format_id,
    material_formats.name AS material_format,
    works.citation_source,
    works.alias_alternates,
    works.cataloging_notes,
    catalogers.id         AS cataloger_id,
    catalogers.name       AS cataloger
  FROM works
    LEFT JOIN countries
      ON works.country_id = countries.id
    LEFT JOIN media_types
      ON works.media_type_id = media_types.id
    LEFT JOIN collections
      ON works.collection_id = collections.id
    LEFT JOIN material_formats
      ON works.material_format_id = material_formats.id
    LEFT JOIN catalogers
      ON works.cataloger_id = catalogers.id
  ORDER BY works.title;

CREATE VIEW composer_title_view AS
  SELECT
    composers.id           AS composer_id,
    composers.name         AS composer_name,
    works.title            AS work_title,
    works.secondary_title  AS work_secondary_title,
    countries.name         AS country,
    media_types.name       AS media_type,
    collections.name       AS collection,
    works.finding_aid_link AS work_finding_aid_link,
    material_formats.name  AS material_format
  FROM works
    LEFT JOIN work_composer
      ON works.id = work_composer.work_id
    LEFT JOIN composers
      ON composers.id = work_composer.composer_id
    LEFT JOIN countries
      ON countries.id = works.country_id
    LEFT JOIN media_types
      ON media_types.id = works.media_type_id
    LEFT JOIN collections
      ON collections.id = works.collection_id
    LEFT JOIN material_formats
      ON material_formats.id = works.material_format_id
    LEFT JOIN catalogers
      ON catalogers.id = works.cataloger_id
  ORDER BY composers.name;

CREATE VIEW director_title_view AS
  SELECT
    directors.id           AS director_id,
    directors.name,
    works.title,
    works.secondary_title,
    countries.name         AS country,
    media_types.name       AS media_type,
    collections.name       AS collection,
    works.finding_aid_link AS work_finding_aid_link,
    material_formats.name  AS material_format
  FROM works
    LEFT JOIN work_director
      ON works.id = work_director.work_id
    LEFT JOIN directors
      ON directors.id = work_director.director_id
    LEFT JOIN countries
      ON countries.id = works.country_id
    LEFT JOIN media_types
      ON media_types.id = works.media_type_id
    LEFT JOIN collections
      ON collections.id = works.collection_id
    LEFT JOIN material_formats
      ON material_formats.id = works.material_format_id
  ORDER BY directors.name;

CREATE VIEW repository_title_view AS
  SELECT
    repositories.id       AS repository_id,
    repositories.name,
    repositories.location,
    repositories.website,
    works.title,
    works.secondary_title,
    countries.name        AS country,
    media_types.name      AS media_type,
    collections.name      AS collection,
    works.finding_aid_link,
    material_formats.name AS material_format
  FROM works
    LEFT JOIN work_repository
      ON works.id = work_repository.work_id
    LEFT JOIN repositories
      ON repositories.id = work_repository.repository_id
    LEFT JOIN countries
      ON countries.id = works.country_id
    LEFT JOIN media_types
      ON media_types.id = works.media_type_id
    LEFT JOIN collections
      ON collections.id = works.collection_id
    LEFT JOIN material_formats
      ON material_formats.id = works.material_format_id
  ORDER BY repositories.name;

CREATE VIEW production_co_title_view AS
  SELECT
    production_companies.id AS production_company_id,
    production_companies.name,
    works.title,
    works.secondary_title,
    countries.name          AS country,
    media_types.name        AS media_type,
    collections.name        AS collection,
    works.finding_aid_link,
    material_formats.name   AS material_format
  FROM works
    JOIN work_production_company
      ON works.id = work_production_company.work_id
    JOIN production_companies
      ON production_companies.id = work_production_company.production_company_id
    LEFT JOIN countries
      ON countries.id = works.country_id
    LEFT JOIN media_types
      ON media_types.id = works.media_type_id
    LEFT JOIN collections
      ON collections.id = works.collection_id
    LEFT JOIN material_formats
      ON material_formats.id = works.material_format_id
  ORDER BY production_companies.name;

CREATE VIEW publisher_title_view AS
  SELECT
    publishers.id         AS publisher_id,
    publishers.name,
    works.title,
    works.secondary_title,
    countries.name        AS country,
    media_types.name      AS media_type,
    collections.name      AS collection,
    works.finding_aid_link,
    material_formats.name AS material_format
  FROM works
    JOIN work_publisher
      ON works.id = work_publisher.work_id
    JOIN publishers
      ON publishers.id = work_publisher.publisher_id
    LEFT JOIN countries
      ON countries.id = works.country_id
    LEFT JOIN media_types
      ON media_types.id = works.media_type_id
    LEFT JOIN collections
      ON collections.id = works.collection_id
    LEFT JOIN material_formats
      ON material_formats.id = works.material_format_id
  ORDER BY publishers.name;
