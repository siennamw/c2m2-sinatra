require 'pg'

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: ENV['DATABASE_NAME'])
    @logger = logger
  end

  def browse_all
    result = query('SELECT * FROM overview_by_work')
    result.map do |tuple|
      tuple_to_list_hash(tuple)
    end
  end

  def browse_composer(id)
    works_sql = 'SELECT work_id FROM work_composer WHERE composer_id = $1'
    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{works_sql})"

    result = query(sql, id).map {|tuple| tuple_to_list_hash(tuple)}

    name, link = get_composer_name_link_by_id(id)
    ["Composer: #{name}", link, result]
  end

  def browse_director(id)
    works_sql = 'SELECT work_id FROM work_director WHERE director_id = $1'
    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{works_sql})"

    result = query(sql, id).map {|tuple| tuple_to_list_hash(tuple)}

    name, link = get_director_name_link_by_id(id)
    ["Director: #{name}", link, result]
  end

  def browse_country(id)
    country, description = get_country_name_desc_by_id(id)

    sql = 'SELECT * FROM overview_by_work WHERE country = $1'

    result = query(sql, country).map do |tuple|
      tuple_to_list_hash(tuple)
    end

    ["Country: #{country}", description, result]
  end

  def browse_media_type(id)
    works_sql = 'SELECT id FROM works WHERE media_type_id = $1'
    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{works_sql})"

    result = query(sql, id).map {|tuple| tuple_to_list_hash(tuple)}

    name, description = get_media_type_name_desc_by_id(id)
    ["Media Type: #{name}", description, result]
  end

  def browse_collection(id)
    works_sql = 'SELECT id FROM works WHERE collection_id = $1'
    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{works_sql})"

    result = query(sql, id).map {|tuple| tuple_to_list_hash(tuple)}

    name, description = get_collection_name_desc_by_id(id)
    ["Collection: #{name}", description, result]
  end

  def browse_material_format(id)
    works_sql = 'SELECT id FROM works WHERE material_format_id = $1'
    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{works_sql})"

    result = query(sql, id).map {|tuple| tuple_to_list_hash(tuple)}

    name, description = get_material_format_name_desc_by_id(id)
    ["Material Format: #{name}", description, result]
  end

  def browse_cataloger(id)
    works_sql = 'SELECT id FROM works WHERE cataloger_id = $1'
    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{works_sql})"

    result = query(sql, id).map {|tuple| tuple_to_list_hash(tuple)}

    name, description = get_cataloger_name_desc_by_id(id)
    ["Cataloger: #{name}", description, result]
  end

  def work_details(id)
    sql = 'SELECT * FROM work_details WHERE work_id = $1'
    result = query(sql, id).first

    if result
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

      # get director and composer names from ids
      # and load into arrays (order must match)

      if hash[:director_ids].include?('&&')
        ids_director = hash[:director_ids].split('&&')

        hash[:director_ids] = []
        hash[:directors] = []

        ids_director.each do |director_id|
          hash[:director_ids] << director_id.to_i
          hash[:directors] << get_director_name_link_by_id(director_id.to_i)[0]
        end
      else
        id = hash[:director_ids].to_i
        hash[:directors] = [get_director_name_link_by_id(id)[0]]
        hash[:director_ids] = [id]
      end

      if hash[:composer_ids].include?('&&')
        ids_composer = hash[:composer_ids].split('&&')

        hash[:composer_ids] = []
        hash[:composers] = []

        ids_composer.each do |composer_id|
          hash[:composer_ids] << composer_id.to_i
          hash[:composers] << get_composer_name_link_by_id(composer_id.to_i)[0]
        end
      else
        id = hash[:composer_ids].to_i
        hash[:composers] = [get_composer_name_link_by_id(id)[0]]
        hash[:composer_ids] = [id]
      end
    else
      hash = nil
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

  def get_composer_name_link_by_id(id)
    sql = 'SELECT name, imdb_link FROM composers WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['imdb_link']]
  end

  def get_director_name_link_by_id(id)
    sql = 'SELECT name, imdb_link FROM directors WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['imdb_link']]
  end

  def get_country_name_desc_by_id(id)
    sql = 'SELECT name, description FROM countries WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['description']]
  end

  def get_media_type_name_desc_by_id(id)
    sql = 'SELECT name, description FROM media_types WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['description']]
  end

  def get_collection_name_desc_by_id(id)
    sql = 'SELECT name, description FROM collections WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['description']]
  end

  def get_material_format_name_desc_by_id(id)
    sql = 'SELECT name, description FROM material_formats WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['description']]
  end

  def get_cataloger_name_desc_by_id(id)
    sql = 'SELECT name, description FROM catalogers WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['description']]
  end
end
