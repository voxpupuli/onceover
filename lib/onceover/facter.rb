require 'facterdb'

class Onceover

  class Facter

    attr_reader :version

    def initialize
      @version = '2.5'
    end

    def facts_by_os(name)

      result = facts(hash_os_details(name)).first
      # FIXME: This behaviour is turned off because of https://github.com/camptocamp/facterdb/issues/58
      # Can leads to wrong factsets for Windows machines (10 and 2016 for sure)
      # if facts.size != 1
      #   raise "Should returns only one facts set, returns #{facts.size} for search #{search_hash}"
      # end
      result

    end

    def os_names(search_hash = {})
      names = []
      facts(search_hash).each do |fact|
        names << "#{fact[:operatingsystem]}-#{fact[:operatingsystemmajrelease]}-#{fact[:architecture]}"
      end
      names.sort
    end

    def windows_os_names
      os_names({ operatingsystem: 'windows' })
    end

    protected

    def facts(search_hash = {})
      FacterDB::get_facts(search_hash.merge(hash_facter_version))
    end

    def hash_facter_version
      { facterversion:  "/^#{@version}\./"}
    end

    def hash_os_details(name)
      os_details_arr = name.split('-')

      os_details_hash = {
        operatingsystem: "'#{os_details_arr[0]}'",
        operatingsystemmajrelease: "'#{os_details_arr[1]}'",
        architecture: "'#{os_details_arr[2]}'"
      }
    end

  end

end
