class MovieService
  class << self
    def call_top_films
      page_one = discover(1)
      page_two = discover(2)
      page_one.merge(page_two) { |_key, p1, p2| p1 + p2 }
    end

    def call_search_films(query)
      page_one = search(query, 1)
      page_two = search(query, 2)
      page_one.merge(page_two) { |_key, p1, p2| p1 + p2 }
    end

    def call_movie_info(mdb_id)
      movie_info(mdb_id)
    end

    private

    def movie_info(mdb_id)
      response = conn.get("movie/#{mdb_id}") do |req|
        req.params['api_key'] = ENV['TMDB_API_KEY']
        req.params['append_to_response'] = 'credits'
      end
      JSON.parse(response.body, symbolize_names: true)
    end

    def discover(page)
      response = conn.get('discover/movie') do |req|
        req.params['api_key'] = ENV['TMDB_API_KEY']
        req.params['sort_by'] = 'popularity.desc'
        req.params['page'] = page
      end
      parse_data(response)
    end

    def search(query, page)
      response = conn.get('search/movie') do |req|
        req.params['api_key'] = ENV['TMDB_API_KEY']
        req.params['query'] = query
        req.params['page'] = page
      end
      parse_data(response)
    end

    def conn
      Faraday.new('https://api.themoviedb.org/3/')
    end
    # Is this necessary? Actually adds two lines of code.
    def parse_data(response)
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end