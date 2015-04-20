module ActiveRecord
  module ActsAs
    module InstanceMethods

      # Allows to query instances regarding their acts_as behavior.
      def is_a? (klass)
        super || acting_as?( klass s)
      end
      def actor?
        self.class.actor?
      end
      def acting_as? (klass = nil)
        self.class.acting_as? klass
      end

      # Helps to build related instances.
      def get_or_build_actable (assoc)
        send( assoc ) || send( "build_#{ assoc }" )
      end

      # Query wether an association is persisted or not.
      def actable_persisted? (assoc)
        !send( assoc ).nil? && !get_or_build_actable(assoc).id.nil? && !foreign_key_for_actable( assoc ).nil?
      end

      # Gets an association foreign key.
      def foreign_key_for_actable (assoc)
        get_or_build_actable( assoc ).send( acts_infos[assoc][:foreign_key] )
      end

      def read_attribute (attr_name, *args, &block)
        if attribute_method? attr_name.to_s
          super
        else
          assoc = acts_infos.keys.find{ |assoc| get_or_build_actable( assoc ).respond_to?( attr_name ) }
          send( assoc ).read_attribute( attr_name, *args, &block )
        end
      end

      def attributes
        super.merge(
          acts_infos.collect do |assoc, infos|
            send( assoc ).attributes.except infos[:type], infos[:foreign_key] if actable_persisted? assoc
          end.inject( :merge )
        )
      end

      def attribute_names
        super | (
          acts_infos.collect do |assoc, infos|
            get_or_build_actable( assoc ).attribute_names - infos.values if actable_persisted? assoc
          end
        ).flatten.uniq
      end

      def first_actable_responding_to (method)
        acts_infos.keys.find { |assoc| get_or_build_actable( assoc ).respond_to?( method ) }
      end

      def respond_to? (name, include_private = false, as_original_class = false)
        found_in_self   = super name, include_private
        if as_original_class
          found_in_self
        else
          found_in_self || first_actable_responding_to( name )!=nil
        end

      end

      def dup
        duplicate = super
        acts_infos.keys.each{ |assoc| duplicate[assoc] = get_or_build_actable( assoc ).dup }
        duplicate
      end

      def method_missing (method, *args, &block)
        if ( assoc = first_actable_responding_to method )
          send( assoc ).send( method, *args, &block )
        else
          super
        end
      end

      def self_respond_to? (name, include_private = false)
        respond_to? name, include_private, true
      end

      protected
        def write_attribute (attr_name, value, *args, &block)
          if attribute_method? attr_name.to_s
            super
          else
            assoc   = acts_infos.keys.find { |name| get_or_build_actable( name ).respond_to?( method ) }
            send( assoc ).send( :write_attribute, attr_name, value, *args, &block )
          end
        end
    end
  end
end
