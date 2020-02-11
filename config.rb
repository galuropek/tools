require_relative 'section'

class Config
	attr_accessor :name
	attr_reader :sections

	def set_sections(sections)
		if sections_are_valid?(sections)
			@sections = prepare_sections(sections)
		else
			puts "PAY ATTENTION!!! Sections have not been parsed:\n#{sections}"
		end
	end

	def sections_are_valid?(sections)
		if sections.is_a?(Array) && sections.any?
			true
		else
			puts "Sections are not Array or sections are empty."
			false
		end
	end

	def prepare_sections(sections)
		prepared_sections = []
		sections.each do |section|
			prepared_sections << parse_section(section)
		end
		prepared_sections
	end

	def parse_section(hash)
		section = Section.new
		section.name = hash["name"]
		section.categories = hash["categories"]
		section
	end
end