require 'csv'
require 'set'

def headers(file)
  csv = File.open(file){|f| f.readline.gsub(/\r/, '')}
  CSV.parse(csv, col_sep: ";").first
end
def compare_headers(file1, file2)
  csv1 = File.open(file1){|f| f.readline.gsub(/\r/, '')}
  csv2 = File.open(file2){|f| f.readline.gsub(/\r/, '')}
  headers1 = Set.new CSV.parse(csv1, col_sep: ";").first
  headers2 = Set.new CSV.parse(csv2, col_sep: ";").first

  puts headers1.to_a.join("\t")
  puts headers2.to_a.join("\t")
  if headers1 != headers2
    puts "##################"
    puts "#{file1} and #{file2} have different headers"
    puts "#{file2} is missing: #{(headers1 - headers2).to_a}"
    puts "#{file1} is missing: #{(headers2 - headers1).to_a}"
    puts "##################"
    puts

  end
end

compare_headers('all_features_v2/dm2_train_sample_all_features_v2.csv', 'all_features_v2/dm2_test_all_features_v2.csv')
compare_headers('all_features_v2/dm2_train_all_features_v2.csv', 'all_features_v2/dm2_test_all_features_v2.csv')

compare_headers('all_features_splited_v2/dm2_sample_v2/dm2_train_sample_known_customer_v2.csv', 'all_features_splited_v2/dm2_sample_v2/dm2_test_kwown_customers_v2.csv')
compare_headers('all_features_splited_v2/dm2_sample_v2/dm2_train_sample_new_customer_v2.csv', 'all_features_splited_v2/dm2_sample_v2/dm2_test_new_customers_v2.csv')

compare_headers('all_features_splited_v2/dm2_train_and_test_v2/dm2_train_known_customer_v2.csv', 'all_features_splited_v2/dm2_train_and_test_v2/dm2_test_kwown_customers_v2.csv')
compare_headers('all_features_splited_v2/dm2_train_and_test_v2/dm2_train_new_customer_v2.csv', 'all_features_splited_v2/dm2_train_and_test_v2/dm2_test_new_customers_v2.csv')

compare_headers('all_features_splited_v2/dm2_train_sample_new_customer_v2.csv', 'all_features_splited_v2/dm2_test_new_customers_v2.csv')
compare_headers('all_features_splited_v2/dm2_train_sample_known_customer_v2.csv', 'all_features_splited_v2/dm2_test_kwown_customers_v2.csv')




compare_headers('all_features_splited_v3/dm2_sample_v3/dm2_train_sample_known_customer_v3.csv', 'all_features_splited_v3/dm2_sample_v3/dm2_test_kwown_customers_v3.csv')
compare_headers('all_features_splited_v3/dm2_sample_v3/dm2_train_sample_new_customer_v3.csv', 'all_features_splited_v3/dm2_sample_v3/dm2_test_new_customers_v3.csv')

compare_headers('all_features_splited_v3/dm2_train_and_test_v3/dm2_train_known_customer_v3.csv', 'all_features_splited_v3/dm2_train_and_test_v3/dm2_test_kwown_customers_v3.csv')
compare_headers('all_features_splited_v3/dm2_train_and_test_v3/dm2_train_new_customer_v3.csv', 'all_features_splited_v3/dm2_train_and_test_v3/dm2_test_new_customers_v3.csv')


folder = "all_features_splited_v4.numeric"
version = "v4"
files = [
  ["dm2_test_kwown_customers_#{version}.numeric.csv", "dm2_train_known_customer_#{version}.numeric.csv"],
  ["dm2_test_new_customers_#{version}.numeric.csv", "dm2_train_new_customer_#{version}.numeric.csv"]
].to_h.each do |test, train|
  test_path  = [folder, test].join("/")
  train_path = [folder, train].join("/")
  compare_headers(test_path, train_path)
end









