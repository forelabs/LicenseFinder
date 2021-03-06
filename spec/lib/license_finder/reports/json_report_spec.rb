# frozen_string_literal: true

require 'json'
require 'spec_helper'

module LicenseFinder
  describe JsonReport do
    it 'understands many columns' do
      dep = Package.new('gem_a', '1.0', authors: 'the authors',
                                        description: 'A description', summary: 'A summary',
                                        homepage: 'http://homepage.example.com')
      dep.decide_on_license(License.find_by_name('MIT'))
      dep.decide_on_license(License.find_by_name('GPL'))
      dep.permitted!
      subject = described_class.new([dep], columns: %w[name version authors licenses approved summary description homepage])
      expected = {
        dependencies:
           [
             {
               name: 'gem_a', version: '1.0', authors: 'the authors', licenses: %w[GPL MIT],
               approved: 'Approved', summary: 'A summary', description: 'A description', homepage: 'http://homepage.example.com'
             }
           ]
      }.to_json

      expect(subject.to_s).to eq(expected)
    end

    it 'supports multiple license texts and joins lines with line feed' do
      install_path = fixture_path('license_directory')
      dep = Package.new('gem_a', '1.0', install_path: install_path)
      subject = described_class.new([dep], columns: %w[name version texts])
      expected = {
        dependencies:
          [
            {
              name: 'gem_a', version: '1.0', texts: "The MIT License\nThe MIT License"
            }
          ]
      }.to_json

      expect(subject.to_s).to eq(expected)
    end
  end
end
