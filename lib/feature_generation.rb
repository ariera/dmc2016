require_relative './shared.rb'

module FeatureGeneration
  NAMESPACE = "train_dm2"
end

require_relative './feature_generation/table.rb'
require_relative './feature_generation/customer_color_history.rb'
require_relative './feature_generation/customer_size_history.rb'
require_relative './feature_generation/order_article_history.rb'
require_relative './feature_generation/order_history.rb'
require_relative './feature_generation/article_history.rb'
require_relative './feature_generation/features.rb'
require_relative './feature_generation/train.rb'

measure = Benchmark.measure do
  # FeatureGeneration::Train.recreate_table
  FeatureGeneration::CustomerColorHistory.recreate_table
  FeatureGeneration::CustomerSizeHistory.recreate_table
  FeatureGeneration::OrderArticleHistory.recreate_table
  FeatureGeneration::ArticleHistory.recreate_table
  FeatureGeneration::OrderHistory.recreate_table
  FeatureGeneration::Features.recreate_table
end

puts measure
