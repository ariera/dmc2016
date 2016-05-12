require_relative './shared.rb'

module FeatureGeneration
  NAMESPACE = "train_dm2"
end

require_relative './feature_generation/table.rb'
require_relative './feature_generation/customer_color_history.rb'
require_relative './feature_generation/customer_size_history.rb'
require_relative './feature_generation/customer_history.rb'
require_relative './feature_generation/order_article_history.rb'
require_relative './feature_generation/order_history.rb'
require_relative './feature_generation/article_history.rb'
require_relative './feature_generation/train_features.rb'
require_relative './feature_generation/test_features.rb'
require_relative './feature_generation/train.rb'
require_relative './feature_generation/train_dm2.rb'
require_relative './feature_generation/test_dm2.rb'



module FeatureGeneration
  def self.generate_datasets
    FeatureGeneration::Train.recreate_table
    FeatureGeneration::TrainDm2.recreate_table
    FeatureGeneration::TestDm2.recreate_table
  end

  def self.generate_train_features
    Table.namespace = "train"

    measure = Benchmark.measure do
      FeatureGeneration::CustomerColorHistory.recreate_table
      FeatureGeneration::CustomerSizeHistory.recreate_table
      FeatureGeneration::CustomerHistory.recreate_table
      FeatureGeneration::OrderArticleHistory.recreate_table
      FeatureGeneration::ArticleHistory.recreate_table
      FeatureGeneration::OrderHistory.recreate_table
      FeatureGeneration::TrainFeatures.recreate_table
    end
    puts measure
  end

  def self.generate_test_features
    Table.namespace = "test"

    measure = Benchmark.measure do
      FeatureGeneration::OrderArticleHistory.recreate_table

      FeatureGeneration::ArticleHistory.override_namespace = "test_and_train"
      FeatureGeneration::ArticleHistory.recreate_table
      FeatureGeneration::OrderHistory.recreate_table
      FeatureGeneration::TestFeatures.recreate_table
    end
    puts measure
  end
end


# FeatureGeneration.generate_test_features
