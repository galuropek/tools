require 'csv'

module Utils

  # @param [Object] argv
  def parse_options(argv)
    argv_line = argv.join(' ')
    return unless argv_line.include?('--options')

    options_line = argv_line.split('--options').last.strip
    options_line.empty? ? nil : options_line.split(' ').map(&:strip)
  end

  # @param [String] path - path to input csv file
  # @param [String] col_sep - column separator in csv file
  def get_table_csv(path, col_sep)
    CSV.parse(File.read(path), headers: true, col_sep: col_sep || "\t")
  end

  def parse_table(table)
    hash = {}
    table.each do |el|
      key = el['cat']
      attribute = el['url']
      hash[key] = {} unless hash[key]
      hash[key][:attr] = attribute
      hash[key][:retailer] = el['retailer']
    end
    hash
  end

  def get_result(hash, breadcrumb_sep)
    result = {}
    if hash.count == 1
      raise 'File has not been parsed. Check col_sep or column names!'
    end

    hash.keys.each do |key|
      breadcrumb = breadcrumb_formatter(key, breadcrumb_sep)
      level = breadcrumb.split('***').count
      retailer = hash[key][:retailer] || 'no_retailer'
      result[retailer] = {} unless result[retailer]
      result[retailer][level] = [] unless result[retailer][level]
      result[retailer][level] << "\"#{breadcrumb}\": \"#{hash[key][:attr]}\""
    end
    result
  end

  def breadcrumb_formatter(key, breadcrumb_sep)
    cats = key.split(breadcrumb_sep)
    cats.map!(&:strip).join(' *** ')
  end

  def print_fast_result(result)
    result.keys.each do |retailer|
      puts retailer
      result[retailer].each { |cr| puts cr }
      puts "=============================\n\n"
    end
  end

  def print_cmd_for_shard(result)
    result.keys.each do |key|
      puts key
      cr_by_levels = result[key]
      levels = cr_by_levels.keys
      levels.each do |lvl|
        parse_breadcrumb_for_cdm(cr_by_levels[lvl])
        puts '--level' + lvl.to_s
      end
    end
  end

  def parse_breadcrumb_for_cdm(cr_array)
    breadcrumbs = []
    urls = []
    cr_array.each do |breadcrumb|
      splitted_cr = breadcrumb.split(': ')
      breadcrumbs << splitted_cr.first
      urls << splitted_cr.last
    end
    puts '--seed_url '
    breadcrumbs.each { |b| puts b + ' ' }
    puts '--seed_path '.chomp
    urls.each { |url| puts url + ' ' }
  end
end