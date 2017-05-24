require 'pg'

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: 'c2m2') #ENV['DATABASE_NAME']
    @logger = logger
  end

  def browse_all
    result = query('SELECT * FROM overview_by_work')
    result.map do |tuple|
      tuple_to_list_hash(tuple)
    end
  end

  def browse_composer(id)
    works_sql = 'SELECT work_id AS id FROM work_composer WHERE composer_id = $1'

    work_result = query(works_sql, id).map { |tuple| tuple['id'].to_i }.join(',')

    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{work_result})"
    result = query(sql).map { |tuple| tuple_to_list_hash(tuple) }

    ["Composer: #{get_composer_name_by_id(id)}", result]
  end

  def browse_director(id)
    works_sql = 'SELECT work_id AS id FROM work_director WHERE director_id = $1'

    work_result = query(works_sql, id).map { |tuple| tuple['id'].to_i }.join(',')

    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{work_result})"
    result = query(sql).map { |tuple| tuple_to_list_hash(tuple) }

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
          media_types.id                            AS media_type_id,
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
          collections.id                            AS collection_id,
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
    sql = <<~SQL
      SELECT
          material_formats.id                       AS material_format_id,
          works.id                                  AS work_id,
          works.title,
          works.secondary_title,
          countries.name                            AS country,
          string_agg(DISTINCT directors.name, ', ') AS director,
          string_agg(DISTINCT composers.name, ', ') AS composer,
          works.year
        FROM material_formats
          LEFT JOIN works
            ON works.material_format_id = material_formats.id
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
        WHERE material_format_id = $1
        GROUP BY works.id, works.title, works.secondary_title, countries.name,
          works.year, material_formats.id
        ORDER BY material_formats.id, works.title;
    SQL

    result = query(sql, id).map do |tuple|
      tuple_to_list_hash(tuple)
    end

    ["Material Format: #{get_material_format_name_by_id(id)}", result]
  end

  def browse_cataloger(id)
    sql = <<~SQL
      SELECT
          catalogers.id                             AS cataloger_id,
          works.id                                  AS work_id,
          works.title,
          works.secondary_title,
          countries.name                            AS country,
          string_agg(DISTINCT directors.name, ', ') AS director,
          string_agg(DISTINCT composers.name, ', ') AS composer,
          works.year
        FROM catalogers
          LEFT JOIN works
            ON works.cataloger_id = catalogers.id
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
        WHERE cataloger_id = $1
        GROUP BY works.id, works.title, works.secondary_title, countries.name,
          works.year, catalogers.id
        ORDER BY catalogers.id, works.title;
    SQL

    result = query(sql, id).map do |tuple|
      tuple_to_list_hash(tuple)
    end

    ["Cataloger: #{get_cataloger_name_by_id(id)}", result]
  end

  def work_details(id)
    sql = 'SELECT * FROM work_details WHERE work_id = $1'
    result = query(sql, id).first

    hash = { id: result['work_id'].to_i,
             title: result['title'],
             secondary_title: result['secondary_title'],
             director_ids: result['director_ids'],
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

    if hash[:director_ids].include?('&&')
      ids_director = hash[:director_ids].split('&&')

      hash[:director_ids] = []
      hash[:directors] = []

      ids_director.each do |director_id|
        hash[:director_ids] << director_id.to_i
        hash[:directors] << get_director_name_by_id(director_id.to_i)
      end
    else
      hash[:directors] = [get_director_name_by_id(hash[:director_ids].to_i)]
      hash[:director_ids] = [hash[:director_ids].to_i]
    end

    if hash[:composer_ids].include?('&&')
      ids_composer = hash[:composer_ids].split('&&')

      hash[:composer_ids] = []
      hash[:composers] = []

      ids_composer.each do |composer_id|
        hash[:composer_ids] << composer_id.to_i
        hash[:composers] << get_composer_name_by_id(composer_id.to_i)
      end
    else
      hash[:composers] = [get_composer_name_by_id(hash[:composer_ids].to_i)]
      hash[:composer_ids] = [hash[:composer_ids].to_i]
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

  def query(statement, *params)
    @logger.info("#{statement}: #{params}")
    @db.exec_params(statement, params)
  end

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
