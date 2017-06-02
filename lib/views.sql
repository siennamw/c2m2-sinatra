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
    works.id                                AS work_id,
    works.title,
    works.secondary_title,
    works.year,
    works.finding_aid_link,
    countries.id                            AS country_id,
    countries.name                          AS country,
    media_types.id                          AS media_type_id,
    media_types.name                        AS media_type,
    material_formats.id                     AS material_format_id,
    material_formats.name                   AS material_format,
    catalogers.id                           AS cataloger_id,
    catalogers.name                         AS cataloger,
    string_agg(work_director.director_id :: TEXT, '&&'
    ORDER BY work_director.director_id)     AS director_ids,
    string_agg(directors.name, '&&'
    ORDER BY directors.id)                  AS directors,
    string_agg(work_composer.composer_id :: TEXT, '&&'
    ORDER BY work_composer.composer_id)     AS composer_ids,
    string_agg(composers.name, '&&'
    ORDER BY composers.id)                  AS composers,
    string_agg(work_collection.collection_id :: TEXT, '&&'
    ORDER BY work_collection.collection_id) AS collection_ids,
    string_agg(collections.name, '&&'
    ORDER BY collections.id)                AS collections,
    string_agg(repositories.id :: TEXT, '&&'
    ORDER BY repositories.id)               AS repository_ids,
    string_agg(repositories.name, '&&'
    ORDER BY repositories.id)               AS repositories

  FROM works
    LEFT JOIN work_director
      ON work_director.work_id = works.id
    LEFT JOIN directors
      ON directors.id = work_director.director_id
    LEFT JOIN work_composer
      ON works.id = work_composer.work_id
    LEFT JOIN composers
      ON composers.id = work_composer.composer_id
    LEFT JOIN work_collection
      ON works.id = work_collection.work_id
    LEFT JOIN collections
      ON work_collection.collection_id = collections.id
    LEFT JOIN repositories
      ON collections.repository_id = repositories.id
    LEFT JOIN countries
      ON works.country_id = countries.id
    LEFT JOIN media_types
      ON works.media_type_id = media_types.id
    LEFT JOIN material_formats
      ON works.material_format_id = material_formats.id
    LEFT JOIN catalogers
      ON works.cataloger_id = catalogers.id
  GROUP BY works.id,
    countries.id,
    media_types.id,
    material_formats.id,
    catalogers.id
  ORDER BY works.title;
