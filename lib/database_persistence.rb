require 'pg'

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: 'c2m2') #ENV['DATABASE_NAME']
    @logger = logger
  end

  def query(statement, *params)
    @logger.info("#{statement}: #{params}")
    @db.exec_params(statement, params)
  end

  def browse_all
    result = query('SELECT * FROM overview_by_work')
    result.map do |tuple|
      tuple_to_list_hash(tuple)
    end
  end

  def browse_composer(id)
    sql = <<~SQL
      SELECT
          composers.id                              AS composer_id,
          works.id                                  AS work_id,
          works.title,
          works.secondary_title,
          countries.name                            AS country,
          string_agg(DISTINCT directors.name, ', ') AS director,
          string_agg(DISTINCT composers.name, ', ') AS composer,
          works.year
        FROM composers
          INNER JOIN work_composer
            ON work_composer.composer_id = composers.id
          LEFT JOIN works
            ON work_composer.work_id = works.id
          LEFT JOIN countries
            ON works.country_id = countries.id
          LEFT JOIN work_director
            ON work_director.work_id = works.id
          LEFT JOIN directors
            ON work_director.director_id = directors.id
        WHERE composer_id = $1
        GROUP BY works.id, works.title, works.secondary_title, countries.name,
          works.year, composers.id
        ORDER BY composers.id, works.title;
    SQL

    result = query(sql, id).map do |tuple|
      tuple_to_list_hash(tuple)
    end

    ["Composer: #{get_composer_name_by_id(id)}", result]
  end

  def browse_director(id)
    sql = <<~SQL
      SELECT
          directors.id                              AS director_id,
          works.id                                  AS work_id,
          works.title,
          works.secondary_title,
          countries.name                            AS country,
          string_agg(DISTINCT directors.name, ', ') AS director,
          string_agg(DISTINCT composers.name, ', ') AS composer,
          works.year
        FROM directors
          INNER JOIN work_director
            ON work_director.director_id = directors.id
          LEFT JOIN works
            ON works.id = work_director.work_id
          LEFT JOIN work_composer
            ON work_composer.work_id = works.id
          LEFT JOIN composers
            ON work_composer.composer_id = composers.id
          LEFT JOIN countries
            ON works.country_id = countries.id
        WHERE director_id = $1
        GROUP BY works.id, works.title, works.secondary_title, countries.name,
          works.year, directors.id
        ORDER BY directors.id, works.title;
    SQL

    result = query(sql, id).map do |tuple|
      tuple_to_list_hash(tuple)
    end

    ["Director: #{get_director_name_by_id(id)}", result]
  end

  def browse_country(id)
    country = get_country_name_by_id(id)
    sql = 'SELECT * FROM overview_by_work WHERE country = $1'
    result = query(sql, country).map do |tuple|
      tuple_to_list_hash(tuple)
    end

    ["Country: #{country}", result]
  end

  def browse_media_type(id)
    sql = <<~SQL
      SELECT
          media_types.id                              AS media_type_id,
          works.id                                  AS work_id,
          works.title,
          works.secondary_title,
          countries.name                            AS country,
          string_agg(DISTINCT directors.name, ', ') AS director,
          string_agg(DISTINCT composers.name, ', ') AS composer,
          works.year
        FROM media_types
          LEFT JOIN works
            ON works.media_type_id = media_types.id
          LEFT JOIN work_composer
            ON work_composer.work_id = works.id
          LEFT JOIN composers
            ON work_composer.composer_id = composers.id
          LEFT JOIN work_director
            ON work_director.work_id = works.id
          LEFT JOIN directors
            ON work_director.director_id = directors.id
          LEFT JOIN countries
            ON works.country_id = countries.id
        WHERE media_type_id = $1
        GROUP BY works.id, works.title, works.secondary_title, countries.name,
          works.year, media_types.id
        ORDER BY media_types.id, works.title;
    SQL

    result = query(sql, id).map do |tuple|
      tuple_to_list_hash(tuple)
    end

    ["Media Type: #{get_media_type_name_by_id(id)}", result]
  end

  def browse_collection(id)
    sql = <<~SQL
      SELECT
          collections.id                              AS collection_id,
          works.id                                  AS work_id,
          works.title,
          works.secondary_title,
          countries.name                            AS country,
          string_agg(DISTINCT directors.name, ', ') AS director,
          string_agg(DISTINCT composers.name, ', ') AS composer,
          works.year
        FROM collections
          LEFT JOIN works
            ON works.collection_id = collections.id
          LEFT JOIN work_composer
            ON work_composer.work_id = works.id
          LEFT JOIN composers
            ON work_composer.composer_id = composers.id
          LEFT JOIN work_director
            ON work_director.work_id = works.id
          LEFT JOIN directors
            ON work_director.director_id = directors.id
          LEFT JOIN countries
            ON works.country_id = countries.id
        WHERE collection_id = $1
        GROUP BY works.id, works.title, works.secondary_title, countries.name,
          works.year, collections.id
        ORDER BY collections.id, works.title;
    SQL

    result = query(sql, id).map do |tuple|
      tuple_to_list_hash(tuple)
    end

    ["Collection: #{get_collection_name_by_id(id)}", result]
  end

  def browse_material_format(id)
    ["Material Format: #{get_material_format_name_by_id(id)}", nil]
  end

  def browse_cataloger(id)
    ["Cataloger: #{get_cataloger_name_by_id(id)}", nil]
  end

  def work_details(id)
    sql = 'SELECT * FROM work_details WHERE work_id = $1'
    result = query(sql, id).first

    hash = { id: result['work_id'].to_i,
             title: result['title'],
             secondary_title: result['secondary_title'],
             directors: result['directors'],
             director_ids: result['director_ids'],
             composers: result['composers'],
             composer_ids: result['composer_ids'],
             year: result['year'].to_i,
             finding_aid_link: result['finding_aid_link'],
             country_id: result['country_id'].to_i,
             country: result['country'],
             media_type_id: result['media_type_id'].to_i,
             media_type: result['media_type'],
             collection_id: result['collection_id'].to_i,
             collection: result['collection'],
             material_format_id: result['material_format_id'].to_i,
             material_format: result['material_format'],
             cataloger_id: result['cataloger_id'].to_i,
             cataloger: result['cataloger']
    }

    directors_array = hash[:directors].split('&&')
    director_ids_array = hash[:director_ids].split('&&')
    composers_array = hash[:composers].split('&&')
    composer_ids_array = hash[:composer_ids].split('&&')

    if hash[:directors] != directors_array
      hash[:directors] = directors_array
      hash[:director_ids] = director_ids_array
    else
      hash[:directors] = [directors_array]
      hash[:director_ids] = [director_ids_array]
    end

    if hash[:composers] != composers_array
      hash[:composers] = composers_array
      hash[:composer_ids] = composer_ids_array
    else
      hash[:composers] = [composers_array]
      hash[:composer_ids] = [composer_ids_array]
    end

    hash
  end

  def catalog_title_view(work_id = nil)
    if work_id
      sql = 'SELECT * FROM catalog_title_view WHERE work_id = $1'
      result = query(sql, work_id)
    else
      sql = 'SELECT * FROM catalog_title_view'
      result = query(sql)
    end

    result.map do |tuple|
      { id: tuple['work_id'].to_i,
        title: tuple['title'],
        secondary_title: tuple['secondary_title'],
        country_id: tuple['country_id'],
        country: tuple['country'],
        media_type_id: tuple['media_type_id'],
        media_type: tuple['media_type'],
        collection_id: tuple['collection_id'],
        collection: tuple['collection'],
        finding_aid_link: tuple['finding_aid_link'],
        material_format: tuple['material_format'],
        material_format_id: tuple['material_format_id'],
        citation_source: tuple['citation_source'],
        alias_alternates: tuple['alias_alternates'],
        cataloging_notes: tuple['cataloging_notes'],
        cataloger_id: tuple['cataloger_id'],
        cataloger: tuple['cataloger']
      }
    end
  end

  private

  def tuple_to_list_hash(tuple)
    { id: tuple['work_id'].to_i,
      title: tuple['title'],
      secondary_title: tuple['secondary_title'],
      country: tuple['country'],
      director: tuple['director'],
      composer: tuple['composer'],
      year: tuple['year'].to_i
    }
  end

  def get_composer_name_by_id(id)
    sql = 'SELECT name FROM composers WHERE id = $1'
    query(sql, id)[0]['name']
  end

  def get_director_name_by_id(id)
    sql = 'SELECT name FROM directors WHERE id = $1'
    query(sql, id)[0]['name']
  end

  def get_country_name_by_id(id)
    sql = 'SELECT name FROM countries WHERE id = $1'
    query(sql, id)[0]['name']
  end

  def get_media_type_name_by_id(id)
    sql = 'SELECT name FROM media_types WHERE id = $1'
    query(sql, id)[0]['name']
  end

  def get_collection_name_by_id(id)
    sql = 'SELECT name FROM collections WHERE id = $1'
    query(sql, id)[0]['name']
  end

  def get_material_format_name_by_id(id)
    sql = 'SELECT name FROM material_formats WHERE id = $1'
    query(sql, id)[0]['name']
  end

  def get_cataloger_name_by_id(id)
    sql = 'SELECT name FROM catalogers WHERE id = $1'
    query(sql, id)[0]['name']
  end
end
