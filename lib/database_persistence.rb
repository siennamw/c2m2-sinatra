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

    name, link = get_composer_info_by_id(id)
    ["Browse Composer: #{name}", link, result]
  end

  def browse_director(id)
    works_sql = 'SELECT work_id FROM work_director WHERE director_id = $1'
    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{works_sql})"

    result = query(sql, id).map {|tuple| tuple_to_list_hash(tuple)}

    name, link = get_director_info_by_id(id)
    ["Browse Director: #{name}", link, result]
  end

  def browse_country(id)
    country, description = get_country_info_by_id(id)

    sql = 'SELECT * FROM overview_by_work WHERE country = $1'

    result = query(sql, country).map do |tuple|
      tuple_to_list_hash(tuple)
    end

    ["Browse Country: #{country}", description, result]
  end

  def browse_media_type(id)
    works_sql = 'SELECT id FROM works WHERE media_type_id = $1'
    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{works_sql})"

    result = query(sql, id).map {|tuple| tuple_to_list_hash(tuple)}

    name, description = get_media_type_info_by_id(id)
    ["Browse Media Type: #{name}", description, result]
  end

  def browse_collection(id)
    works_sql = 'SELECT work_id FROM work_collection WHERE collection_id = $1'
    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{works_sql})"

    result = query(sql, id).map {|tuple| tuple_to_list_hash(tuple)}

    name, description, repository_id = get_collection_info_by_id(id)

    repository_name, _ = get_repository_info_by_id(repository_id.to_i)
    ["Browse Collection: #{name}", description, repository_name, repository_id, result]
  end

  def browse_repository(id)
    works_sql = <<~SQL
      SELECT work_id
        FROM work_collection 
        LEFT JOIN collections ON collections.id = work_collection.collection_id
        LEFT JOIN repositories ON repositories.id = collections.repository_id
        WHERE repository_id = $1
    SQL
    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{works_sql})"

    result = query(sql, id).map {|tuple| tuple_to_list_hash(tuple)}

    name, location, website = get_repository_info_by_id(id)
    ["Browse Repository: #{name}", location, website, result]
  end

  def browse_material_format(id)
    works_sql = 'SELECT id FROM works WHERE material_format_id = $1'
    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{works_sql})"

    result = query(sql, id).map {|tuple| tuple_to_list_hash(tuple)}

    name, description = get_material_format_info_by_id(id)
    ["Browse Material Format: #{name}", description, result]
  end

  def browse_cataloger(id)
    works_sql = 'SELECT id FROM works WHERE cataloger_id = $1'
    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{works_sql})"

    result = query(sql, id).map {|tuple| tuple_to_list_hash(tuple)}

    name, description = get_cataloger_info_by_id(id)
    ["Browse Cataloger: #{name}", description, result]
  end

  def browse_year(year)
    works_sql = 'SELECT id FROM works WHERE year = $1'
    sql = "SELECT * FROM overview_by_work WHERE work_id IN(#{works_sql})"

    result = query(sql, year).map {|tuple| tuple_to_list_hash(tuple)}

    ["Browse Year: #{year}", result]
  end

  def work_details(id)
    sql = 'SELECT * FROM work_details WHERE work_id = $1'
    result = query(sql, id).first

    if result
      { id: result['work_id'].to_i,
        title: result['title'],
        secondary_title: result['secondary_title'],
        year: result['year'].to_i,
        finding_aid_link: result['finding_aid_link'],
        country_id: result['country_id'].to_i,
        country: result['country'],
        media_type_id: result['media_type_id'].to_i,
        media_type: result['media_type'],
        material_format_id: result['material_format_id'].to_i,
        material_format: result['material_format'],
        cataloger_id: result['cataloger_id'].to_i,
        cataloger: result['cataloger'],

        # arrays from here down
        director_ids: delimited_list_to_a(result['director_ids']),
        directors: delimited_list_to_a(result['directors']),
        composer_ids: delimited_list_to_a(result['composer_ids']),
        composers: delimited_list_to_a(result['composers']),
        collection_ids: delimited_list_to_a(result['collection_ids']),
        collections: delimited_list_to_a(result['collections']),
        repository_ids: delimited_list_to_a(result['repository_ids']),
        repositories: delimited_list_to_a(result['repositories'])
      }
    end
  end

  private

  def query(statement, *params)
    @logger.info("#{statement}: #{params}")
    @db.exec_params(statement, params)
  end

  def delimited_list_to_a(string)
    if string && string.include?('&&')
      string.split('&&').uniq
    else
      [string]
    end
  end

  def tuple_to_list_hash(tuple)
    { id: tuple['work_id'].to_i,
      title: tuple['title'],
      secondary_title: tuple['secondary_title'],
      country: tuple['country'],
      director: tuple['director'],
      composer: tuple['composer'],
      year: tuple['year'].to_i }
  end

  def get_composer_info_by_id(id)
    sql = 'SELECT name, imdb_link FROM composers WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['imdb_link']]
  end

  def get_director_info_by_id(id)
    sql = 'SELECT name, imdb_link FROM directors WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['imdb_link']]
  end

  def get_country_info_by_id(id)
    sql = 'SELECT name, description FROM countries WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['description']]
  end

  def get_media_type_info_by_id(id)
    sql = 'SELECT name, description FROM media_types WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['description']]
  end

  def get_collection_info_by_id(id)
    sql = 'SELECT name, description, repository_id FROM collections WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['description'], result['repository_id']]
  end

  def get_repository_info_by_id(id)
    sql = 'SELECT name, location, website FROM repositories WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['location'], result['website']]
  end

  def get_material_format_info_by_id(id)
    sql = 'SELECT name, description FROM material_formats WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['description']]
  end

  def get_cataloger_info_by_id(id)
    sql = 'SELECT name, description FROM catalogers WHERE id = $1'
    result = query(sql, id).first
    [result['name'], result['description']]
  end
end
