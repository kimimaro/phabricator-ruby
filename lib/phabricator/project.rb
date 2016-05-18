require_relative 'conduit_client'

module Phabricator
  class Project < PhabObject
    @@cached_projects_hash = {}
    @@cached_open_projects = []

    prop :id
    prop :name
    prop :slugs, class: Array

    def self.populate_all
      #FIXME: hard code limit 999 to get all projects
      query(limit: 999).each do |project|
        @@cached_projects_hash[project.name.downcase] = project
      end
    end

    def self.fetch_all_open
      #FIXME: hard code limit 999 to get all projects
      @@cached_open_projects = query({status: "status-open", limit: 999})
    end

    def self.find_by_name(name)
      populate_all if @@cached_projects_hash.empty?

      @@cached_projects_hash[name.downcase] || refresh_cache_for_project(name)
    end

    # return projectHash List
    def self.fuzzy_find_by_query(query)
      populate_all if @@cached_projects_hash.empty?

      items = Array.new()

      @@cached_projects_hash.each do |name, project|
        if name.include?(query) then
          slug = project.slugs[0]
          if slug then
            items.push(slug)
          end
        end
      end

      items
    end

    def self.find_all_open
      fetch_all_open if @@cached_open_projects.empty?

      @@cached_open_projects || refresh_cache_open_projects()
    end

    def self.raw_value_from_name(name)
      return nil if name.nil?

      project = find_by_name(name)
      return nil if project.nil?
      return project.phid
    end

    def self.name_from_raw_value(raw_value)
      # TODO: implement me
      raise NotImplementedError
    end

    private

    def self.refresh_cache_for_project(name)
      query(names: [name]).each do |project|
        @@cached_projects_hash[project.name.downcase] = project
      end

      @@cached_projects_hash[name.downcase]
    end

    def self.refresh_cache_open_projects()
      @@cached_open_projects = query({status: "status-open", limit: 999})
    end
  end
end
