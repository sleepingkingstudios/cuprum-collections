# frozen_string_literal: true

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of a Collection.
  COLLECTION_CONTRACT = lambda do
    shared_examples 'should define the command' do |command_name, command_class|
      tools      = SleepingKingStudios::Tools::Toolbelt.instance
      class_name = tools.str.camelize(command_name)

      describe "::#{class_name}" do
        let(:constructor_options) { {} }
        let(:command) do
          collection.const_get(class_name).new(**constructor_options)
        end

        it { expect(collection).to define_constant(class_name) }

        it { expect(collection.const_get(class_name)).to be_a Class }

        it { expect(collection.const_get(class_name)).to be < command_class }

        command_options.each do |option_name|
          it "should set the ##{option_name}" do
            expect(command.send(option_name))
              .to be == collection.send(option_name)
          end
        end

        describe 'with options' do
          let(:constructor_options) do
            {
              data:        [],
              member_name: 'tome'
            }
          end

          command_options.each do |option_name|
            it "should set the ##{option_name}" do
              expect(command.send(option_name)).to(
                be == constructor_options.fetch(option_name) do
                  collection.send(option_name)
                end
              )
            end
          end
        end
      end

      describe "##{command_name}" do
        let(:constructor_options) { {} }
        let(:command) do
          collection.send(command_name, **constructor_options)
        end

        it 'should define the command' do
          expect(collection)
            .to respond_to(command_name)
            .with(0).arguments
            .and_any_keywords
        end

        it { expect(command).to be_a collection.const_get(class_name) }

        command_options.each do |option_name|
          it "should set the ##{option_name}" do
            expect(command.send(option_name))
              .to be == collection.send(option_name)
          end
        end

        describe 'with options' do
          let(:constructor_options) do
            {
              data:        [],
              member_name: 'tome'
            }
          end

          command_options.each do |option_name|
            it "should set the ##{option_name}" do
              expect(command.send(option_name)).to(
                be == constructor_options.fetch(option_name) do
                  collection.send(option_name)
                end
              )
            end
          end
        end
      end
    end

    include_examples 'should define the command',
      :assign_one,
      commands_namespace::AssignOne

    include_examples 'should define the command',
      :build_one,
      commands_namespace::BuildOne

    include_examples 'should define the command',
      :destroy_one,
      commands_namespace::DestroyOne

    include_examples 'should define the command',
      :find_many,
      commands_namespace::FindMany

    include_examples 'should define the command',
      :find_matching,
      commands_namespace::FindMatching

    include_examples 'should define the command',
      :find_one,
      commands_namespace::FindOne

    include_examples 'should define the command',
      :insert_one,
      commands_namespace::InsertOne

    include_examples 'should define the command',
      :update_one,
      commands_namespace::UpdateOne

    include_examples 'should define the command',
      :validate_one,
      commands_namespace::ValidateOne

    describe '#query' do
      let(:query) { collection.query }

      it { expect(collection).to respond_to(:query).with(0).arguments }

      it { expect(collection.query).to be_a Cuprum::Collections::Basic::Query }

      it { expect(query.criteria).to be == [] }

      it { expect(query.limit).to be nil }

      it { expect(query.offset).to be nil }

      it { expect(query.order).to be == {} }
    end
  end
end
