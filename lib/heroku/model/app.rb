require 'heroku/model/model_helper'
require 'git'

module Heroku
  module Model
    class App < Struct.new(
      :parent,
      :id,
      :name,
      :owner,
      :region,
      :git_url,
      :web_url,
      :repo_size,
      :slug_size,
      :buildpack_provided_description,
      :stack,
      :maintenance,
      :archived_at,
      :created_at,
      :released_at,
      :updated_at
    )

      include Heroku::Model::ModelHelper

      def inspect
        "#<#{self.class.name} #{identifier}>"
      end

      def initialize(params = {})
        super(*struct_init_from_hash(params))
      end

      def push(dir)
        begin
          Git.open(dir, log: Heroku::Properties.logger).push(git_url)
          true
        rescue => e
          Heroku::Properties.logger.error(e.message)
          e.backtrace.each do |line|
            Heroku::Properties.logger.error(line)
          end

          false
        end
      end

      def patchable
        sub_struct_as_hash(:maintenance, :name)
      end

      def identifiable
        sub_struct_as_hash(:id, :name)
      end

      def end_point
        "/apps/#{id}"
      end

      def save
        parent.update_app(self)
      end

      def destroy
        parent.delete_app(self)
      end
    end
  end
end
