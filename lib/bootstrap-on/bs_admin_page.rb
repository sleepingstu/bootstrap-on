module Padrino
  module Generators
    ##
    # Defines the generator for creating a new admin page.
    #
    class BsAdminPage < Thor::Group
      attr_accessor :default_orm

      # Add this generator to our padrino-gen
      Padrino::Generators.add_generator(:bs_admin_page, self)

      # Define the source template root
      def self.source_root; File.expand_path(File.dirname(__FILE__)); end
      # Defines the "banner" text for the CLI.
      def self.banner; "padrino g bs_admin_page [model]"; end

      # Include related modules
      include Thor::Actions
      include Padrino::Generators::Actions
      include Padrino::Generators::Admin::Actions

      desc "Description:\n\n\tpadrino g bs_admin_page [model(s)] - Generates a new Padrino Admin page with Twitter Bootstrapped integrated"

      argument :models, :desc => "The name(s) of your model(s)", :type => :array
      class_option :skip_migration, :aliases => "-s", :default => false, :type => :boolean
      class_option :root, :desc => "The root destination", :aliases => '-r', :type => :string
      class_option :destroy, :aliases => '-d', :default => false, :type => :boolean

      # Show help if no argv given
      require_arguments!

      # Create controller for admin
      def create_controller
        self.destination_root = options[:root]
        if in_app_root?
          models.each do |model|
            @orm = default_orm || Padrino::Admin::Generators::Orm.new(model, adapter)
            self.behavior = :revoke if options[:destroy]
            empty_directory destination_root("/admin/views/#{@orm.name_plural}")

            template "templates/page/controller.rb.tt",       destination_root("/admin/controllers/#{@orm.name_plural}.rb")
            template "templates/#{ext}/page/_form.#{ext}.tt", destination_root("/admin/views/#{@orm.name_plural}/_form.#{ext}")
            template "templates/#{ext}/page/edit.#{ext}.tt",  destination_root("/admin/views/#{@orm.name_plural}/edit.#{ext}")
            template "templates/#{ext}/page/index.#{ext}.tt", destination_root("/admin/views/#{@orm.name_plural}/index.#{ext}")
            template "templates/#{ext}/page/new.#{ext}.tt",   destination_root("/admin/views/#{@orm.name_plural}/new.#{ext}")

            options[:destroy] ? remove_project_module(@orm.name_plural) : add_project_module(@orm.name_plural)
          end
        else
          say "You are not at the root of a Padrino application! (config/boot.rb not found)"
        end
      end
    end # AdminPage
  end # Generators
end # Padrino