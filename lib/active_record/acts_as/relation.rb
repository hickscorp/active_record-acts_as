module ActiveRecord
  module ActsAs
    module Relation
      extend ActiveSupport::Concern
      module ClassMethods
        def acts_as (name, scope = nil, options = {})
          name                    = name.to_sym
          options, scope          = scope, nil if Hash === scope
          options                 = {
                                    as:         :actable,
                                    dependent:  :destroy,
                                    validate:   false,
                                    autosave:   true
                                  }.merge options

          # Store acts_as informations at class-level.
          cattr_reader            :acts_infos do
            @acts_infos             ||= {}
          end

          # First time calling acts_as, include common methods.
          if acts_infos.empty?
            # When querying this model, include all his actable models.
            default_scope           do
              ret                     = self
              acts_infos.each { |assoc, infos| ret = ret.eager_load assoc }
              ret
            end
            # Automatically builds all actable related objects.
            after_initialize if: :new_record? do
              acts_infos.keys.each{ |assoc| get_or_build_actable assoc }
            end
            # Automatically validates all actable related objects.
            validate do
              acts_infos.each do |assoc, infos|
                unless ( obj = get_or_build_actable assoc ).valid?
                  obj.errors.each do |attr, message|
                    errors.add attr, message
                  end
                end
              end
            end
            include ActsAs::InstanceMethods
          end

          # Create the association.
          assoc                   = ( has_one name, scope, options ).stringify_keys[name.to_s]
          # Store some information about the association.
          acts_infos[name]        = {
            type:                   assoc.type,
            foreign_key:            assoc.foreign_key,
            klass:                  ( options[:class_name] || name.to_s.camelize ).constantize,
            options:                options
          }
        end

        def actable (options = {})
          name                  = options.delete( :as ) || :actable
          reflections           = belongs_to name, { polymorphic: true, dependent: :delete, autosave: true }.merge(options)
          cattr_reader          :actable_reflection do
            reflections.stringify_keys[name.to_s]
          end
        end

        def is_a? (klass)
          super || acting_as?( klass )
        end
        def actor?
          respond_to? :acts_infos
        end
        def acting_as? (other = nil)
          if actor?
            case other
            when NilClass
              true
            when Symbol
              acts_infos.keys.include? other
            when String
              acts_infos.keys.include? other.to_sym
            when Class
              acts_infos.keys.include? other.to_s.underscore.to_sym
            else
              false
            end
          else
            false
          end
        end
        def actable?
          respond_to?( :actable_reflection ) && actable_reflection.is_a?( ActiveRecord::Reflection::AssociationReflection )
        end
      end
    end
  end
end
