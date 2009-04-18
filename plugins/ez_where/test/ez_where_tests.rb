require File.dirname(__FILE__) + '/test_helper'

class PluralizeClause < Caboose::EZ::AbstractClause
  
  def initialize(name, value)
    @outer = :and
    @test = :pluralize
    @name, @value = name, value
  end
  
  def to_sql
    cond = Caboose::EZ::Condition.new :inner => :or
    cond.clause(@name) == @value.singularize
    cond.clause(@name) == @value.singularize.pluralize
    cond.to_sql
  end
  
  def empty?
    @value.to_s.empty?
  end
  
end

class EZWhereTest < Test::Unit::TestCase
  
  fixtures :articles, :authors, :comments
  
  def test_ez_where
      cond = Caboose::EZ::Condition.new do
      foo == 'bar'
      baz <=> (1..5)
      id === [1, 2, 3, 5, 8]
    end

    expected = ["foo = ? AND baz BETWEEN ? AND ? AND id IN (?)", "bar", 1, 5, [1, 2, 3, 5, 8]]
    assert_equal expected, cond.to_sql

    cond = Caboose::EZ::Condition.new :my_table do
      foo == 'bar'
      baz <=> (1..5)
      id === [1, 2, 3, 5, 8]
    end

    expected = ["my_table.foo = ? AND my_table.baz BETWEEN ? AND ? AND my_table.id IN (?)", "bar", 1, 5, [1, 2, 3, 5, 8]]
    assert_equal expected, cond.to_sql

    cond = Caboose::EZ::Condition.new :my_table do
      foo == 'bar'
      baz <=> (1..5)
      id === [1, 2, 3, 5, 8]
      condition :my_other_table do
        fiz =~ '%faz%'
      end
    end

    expected = ["my_table.foo = ? AND my_table.baz BETWEEN ? AND ? AND my_table.id IN (?) AND (my_other_table.fiz LIKE ?)", "bar", 1, 5, [1, 2, 3, 5, 8], "%faz%"]
    assert_equal expected, cond.to_sql

    cond = Caboose::EZ::Condition.new :my_table do
      foo == 'bar'
      baz <=> (1..5)
      id === [1, 2, 3, 5, 8]
      condition :my_other_table do
        fiz =~ '%faz%'
      end
    end

    expected = ["my_table.foo = ? AND my_table.baz BETWEEN ? AND ? AND my_table.id IN (?) AND (my_other_table.fiz LIKE ?)", "bar", 1, 5, [1, 2, 3, 5, 8], "%faz%"]
    assert_equal expected, cond.to_sql

    cond_a = Caboose::EZ::Condition.new :my_table do
      foo == 'bar'
      condition :my_other_table do
        id === [1, 3, 8]
        foo == 'other bar'
        fiz =~ '%faz%'
      end
    end

    expected = ["my_table.foo = ? AND (my_other_table.id IN (?) AND my_other_table.foo = ? AND my_other_table.fiz LIKE ?)", "bar", [1, 3, 8], "other bar", "%faz%"]
    assert_equal expected, cond_a.to_sql

    cond_b = Caboose::EZ::Condition.new :my_table do
      active == true
      archived == false
    end

    expected = ["my_table.active = ? AND my_table.archived = ?", true, false]
    assert_equal expected, cond_b.to_sql

    composed_cond = Caboose::EZ::Condition.new
    composed_cond << cond_a
    composed_cond << cond_b.to_sql
    composed_cond << 'fuzz IS NULL'

    expected = ["(my_table.foo = ? AND (my_other_table.id IN (?) AND my_other_table.foo = ? AND my_other_table.fiz LIKE ?)) AND (my_table.active = ? AND my_table.archived = ?) AND fuzz IS NULL", "bar", [1, 3, 8], "other bar", "%faz%", true, false]   
    assert_equal expected, composed_cond.to_sql

    cond = Caboose::EZ::Condition.new :my_table do
      foo == 'bar'
      any :my_other_table do
        baz === ['fizz', 'fuzz']
        biz == 'boz'
      end
    end

    expected = ["my_table.foo = ? AND (my_other_table.baz IN (?) OR my_other_table.biz = ?)", "bar", ["fizz", "fuzz"], "boz"]
    assert_equal expected, cond.to_sql

    cond = Caboose::EZ::Condition.new :my_table do
      foo == 'bar'
      any do
        baz === ['fizz', 'fuzz']
        biz == 'boz'
      end
    end

    expected = ["my_table.foo = ? AND (my_table.baz IN (?) OR my_table.biz = ?)", "bar", ["fizz", "fuzz"], "boz"]
    assert_equal expected, cond.to_sql

    cond = Caboose::EZ::Condition.new do
      foo == 'bar'
      any do
        baz === ['fizz', 'fuzz']
        biz == 'boz'
      end      
    end

    expected = ["foo = ? AND (baz IN (?) OR biz = ?)", "bar", ["fizz", "fuzz"], "boz"]
    assert_equal expected, cond.to_sql

    cond = Caboose::EZ::Condition.new do
      foo == 'bar'
      add_sql ['baz = ? AND bar IS NOT NULL', 'fuzz']
    end

    expected = ["foo = ? AND (baz = ? AND bar IS NOT NULL)", "bar", "fuzz"]
    assert_equal expected, cond.to_sql

    cond = Caboose::EZ::Condition.new
    cond.foo == 'bar'
    cond << ['baz = ? AND bar IS NOT NULL', 'fuzz']

    expected = ["foo = ? AND (baz = ? AND bar IS NOT NULL)", "bar", "fuzz"]
    assert_equal expected, cond.to_sql   
  end
  
  def test_compose_condition
    ar_instance = Author.find(1)
    
    other_cond = Caboose::EZ::Condition.new :my_table do 
      foo == 'bar'; baz == 'buzz'
    end
  
    cond = Caboose::EZ::Condition.new
    # another Condition
    cond.append other_cond
    # an array in AR condition format
    cond.append ['baz = ? AND bar IS NOT NULL', 'fuzz'], :or
    # a raw SQL string
    cond.append 'biz IS NULL'
    # an Active Record instance from DB or as Value Object
    cond.append ar_instance
    
    expected = ["(my_table.foo = ? AND my_table.baz = ?) OR (baz = ? AND bar IS NOT NULL) AND biz IS NULL AND authors.id = ?", "bar", "buzz", "fuzz", 1]
    assert_equal expected, cond.to_sql  
  end
  
  def test_ez_find
    articles = Article.ez_find(:all, :conditions => ['authors.id = ?', 1], :include => :author, :limit => 1)   
    assert_equal 1, articles.length
    
    articles = Article.ez_find(:all, :include => :author, :limit => 1) do |article, author|
      author.id == 1
    end    
    assert_equal 1, articles.length
    
    articles = Article.ez_find(:all, :include => :author) do |article, author|
      article.title =~ "Wh%"
    end    
    assert_equal 2, articles.length   
    
    articles = Article.ez_find(:all, :include => :author) do |article, author|
      article.title =~ "Wh%"
      author.id == 1
    end    
    assert_equal 1, articles.length 
    
    articles = Article.ez_find(:all, :include => :author, :limit => 1) do |article, author|
      author.name =~ 'Ez%'
    end
    assert_equal 1, articles.length   
  end
  
  def test_ez_find_with_more_complex_queries
    $DEBUG = true
    ezra = Author.find(2)    
    
    # all articles written by Ezra
    articles = Article.ez_find(:all, :include => :author) do |article, author|
      author << ezra # use AR instance to add condition; uses PK value if set: author.id = ezra.id
    end 
    assert articles.length >= 1
    
    # all articles written by Ezra, where he himself responds in comments
    articles = Article.ez_find(:all, :include => [:author, :comments]) do |article, author, comment|
      article.author_id == ezra.id
      comment.author_id == ezra.id   
    end
    assert_equal 1, articles.length 
    
    # any articles written by Fab or Ezra
    articles = Article.ez_find(:all, :include => :author) do |article, author|
      author.name === ['Fab', 'Ezra']   
    end
    assert articles.length >= 1 
    
    # any articles written by Fab or Ezra, using subcondition
    articles = Article.ez_find(:all, :include => :author) do |article, author|
      author.any do
        name == 'Ezra'
        name == 'Fab'
      end  
    end
    assert articles.length >= 1
    
    # any articles written by or commented on by Fab, using subcondition
    articles = Article.ez_find(:all, :include => [:author, :comments]) do |article, author, comment|
      article.author_id == 1
      comment.outer = :or # set :outer for the comment condition, since it defaults to :and
      comment.author_id == 1       
    end
    assert articles.length >= 1  
  end
  
  def test_ez_find_with_outer_and_inner_mapping
    # any articles written by Fab or Ezra or commented on by Fab, using subcondition and preset :outer and :inner
    articles = Article.ez_find(:all, :include => [:author, :comments], :outer => { :comments => :or }, :inner => { :article => :or }) do |article, author, comment|
      article.author_id == 1
      article.author_id == 2
      comment.author_id == 1       
    end
    assert articles.length >= 1  
  end
  
  def test_ez_condition
    cond = Article.ez_condition { active == true; archived == false }
    cond.any { title =~ '%article%'; title =~ '%first%' }
    
    expected = ["articles.active = ? AND articles.archived = ? AND (articles.title LIKE ? OR articles.title LIKE ?)",
     true,
     false,
     "%article%",
     "%first%"]
    assert_equal expected, cond.to_sql
    
    cond = Article.ez_condition { active == true; archived == false }
    cond.all { body =~ '%intro%'; body =~ '%demo%' }
    cond.any { title =~ '%article%'; title =~ '%first%' }
    
    expected = ["articles.active = ? AND articles.archived = ? AND (articles.body LIKE ? AND articles.body LIKE ?) AND (articles.title LIKE ? OR articles.title LIKE ?)",
     true,
     false,
     "%intro%",
     "%demo%",
     "%article%",
     "%first%"]
    assert_equal expected, cond.to_sql    
  end
  
 def test_negate_ez_where   
   cond = Caboose::EZ::Condition.new :my_table do
     foo! == 'bar'
     baz! <=> (1..5)
     id! === [1, 2, 3, 5, 8]
   end    
   expected = ["my_table.foo != ? AND my_table.baz NOT BETWEEN ? AND ? AND my_table.id NOT IN (?)", "bar", 1, 5, [1, 2, 3, 5, 8]]
   assert_equal expected, cond.to_sql  
 end
 
 def test_negate_condition
   cond = Caboose::EZ::Condition.new :my_table do
     any { foo == 'bar'; name == 'rails' }
     all { baz! == 'buzz'; name! == 'loob' }
   end
   expected = ["(my_table.foo = ? OR my_table.name = ?) AND (my_table.baz != ? AND my_table.name != ?)", "bar", "rails", "buzz", "loob"]
   assert_equal expected, cond.to_sql(:not)
 end
  
  def test_complex_sub_condition
    cond = Caboose::EZ::Condition.new :my_table do
      any { foo == 'bar'; name == 'rails' }
      sub :table_name => :my_other_table, :outer => :and, :inner => :or do 
        all { fud == 'bar'; flip == 'rails' }        
        sub :outer => :not, :inner => :or do 
          color == 'yellow'
          finish == 'glossy'
          sub :outer => :or do
            baz == 'buzz'
            name == 'loob'
          end
        end      
      end     
    end
    expected = ["(my_table.foo = ? OR my_table.name = ?) AND ((my_other_table.fud = ? AND my_other_table.flip = ?) AND NOT (my_other_table.color = ? OR my_other_table.finish = ? OR (my_other_table.baz = ? AND my_other_table.name = ?)))",
     "bar",
     "rails",
     "bar",
     "rails",
     "yellow",
     "glossy",
     "buzz",
     "loob"]
    assert_equal expected, cond.to_sql
  end
  
  def test_define_sub_condition_syntax_refinements
    
    # these are here to stir the discussion on the final public API methods
    
    cond1 = Caboose::EZ::Condition.new :my_table do 
      foo == 'bar'
      any do
        baz === ['fizz', 'fuzz']
        biz == 'boz'
      end
    end

    cond2 = Caboose::EZ::Condition.new :my_table do 
      foo == 'bar'
      sub :outer => :and, :inner => :or do
        baz === ['fizz', 'fuzz']
        biz == 'boz'
      end
    end
    
    cond3 = Caboose::EZ::Condition.new :my_table do 
      foo == 'bar'
      my_table :outer => :and, :inner => :or do
        baz === ['fizz', 'fuzz']
        biz == 'boz'
      end
    end
    
    expected = ["my_table.foo = ? AND (my_table.baz IN (?) OR my_table.biz = ?)", "bar", ["fizz", "fuzz"], "boz"]
    assert_equal cond1.to_sql, cond2.to_sql
    assert_equal cond1.to_sql, cond3.to_sql
    assert_equal expected, cond1.to_sql
    
    cond = Caboose::EZ::Condition.new :my_table do 
      foo == 'bar'
      my_table :outer => :or do
        baz == 'fuzz'
        biz == 'boz'
      end
    end
    
    expected = ["my_table.foo = ? OR (my_table.baz = ? AND my_table.biz = ?)", "bar", "fuzz", "boz"]
    assert_equal expected, cond.to_sql
       
    cond1 = Caboose::EZ::Condition.new :my_table do 
      foo == 'bar'
      my_table do
        baz == 'fuzz'
        biz == 'boz'
      end
    end
    
    cond2 = Caboose::EZ::Condition.new :my_table do 
      foo == 'bar'
      sub do
        baz == 'fuzz'
        biz == 'boz'
      end
    end
    
    expected = ["my_table.foo = ? AND (my_table.baz = ? AND my_table.biz = ?)", "bar", "fuzz", "boz"]
    assert_equal cond1.to_sql, cond2.to_sql
    assert_equal expected, cond1.to_sql   
  end
  
  def test_clause_method
    cond = Caboose::EZ::Condition.new :my_table
    cond.clause(:foo) == 'bar'
    cond.clause(:baz) <=> (1..5)
    cond.clause(:id) === [1, 2, 3, 5, 8]
    
    expected = ["my_table.foo = ? AND my_table.baz BETWEEN ? AND ? AND my_table.id IN (?)", "bar", 1, 5, [1, 2, 3, 5, 8]]
    assert_equal expected, cond.to_sql
    
    cond = Caboose::EZ::Condition.new :my_table
    cond.clause(:foo!) == 'bar'
    cond.clause(:baz) == 'buzz'
    expected = ["my_table.foo != ? AND my_table.baz = ?", "bar", "buzz"]
    assert_equal expected, cond.to_sql
  end
  
  def test_null_value_to_sql
    cond = Caboose::EZ::Condition.new :my_table do
      any { foo == 'bar'; name == 'rails' }
      all { baz == :null; name! == :null }
    end
    expected = ["(my_table.foo = ? OR my_table.name = ?) AND (my_table.baz IS NULL AND my_table.name IS NOT NULL)", "bar", "rails"]
    assert_equal expected, cond.to_sql
  end
  
  def test_clone_from_active_record_instance
    author = Author.find(2)
    
    # AR instance as Value Object
    article = Article.new do |a|
      a.title = 'Article One'
      a.author = author # convenient...
    end
    
    assert_equal 2, article.author_id
    
    cond = Caboose::EZ::Condition.new
    cond.clone_from article
    
    expected = ["articles.title = ? AND articles.author_id = ?", "Article One", 2]
    assert_equal expected, cond.to_sql
    
    cond = Caboose::EZ::Condition.new
    cond << article
    assert_equal expected, cond.to_sql
    
    # AR instance, based on primary key only
    cond = Caboose::EZ::Condition.new
    cond << author
    cond << Article.find(1)
    
    expected = ["authors.id = ? AND articles.id = ?", 2, 1]
    assert_equal expected, cond.to_sql
  end
  
  def test_custom_clause_class
    cond = Caboose::EZ::Condition.new :my_table
    cond << PluralizeClause.new('column', 'person')
    cond << PluralizeClause.new('other_column', 'car')  
    cond << PluralizeClause.new('another_column', 'house') 
    expected = ["(column = ? OR column = ?) AND (other_column = ? OR other_column = ?) AND (another_column = ? OR another_column = ?)", "person", "people", "car", "cars", "house", "houses"]
    assert_equal expected, cond.to_sql
  end
  
  def test_conditions_hash
    sql = { 'name' => 'fab', 'country' => 'Belgium' }.to_sql
    assert_equal "name = 'fab' AND country = 'Belgium'", sql
    
    conditions = { 'name' => 'fab', 'country' => 'Belgium' }.to_conditions
    assert_equal ["name = ? AND country = ?", "fab", "Belgium"], conditions
    
    cond = Caboose::EZ::Condition.new :my_table
    cond.any { foo == 'bar'; name == 'rails' }
    cond.append 'name' => 'fab', 'country' => 'Belgium'
    expected = ["(my_table.foo = ? OR my_table.name = ?) AND (name = ? AND country = ?)", "bar", "rails", "fab", "Belgium"]
    assert_equal expected, cond.to_sql
  end
  
  def test_append_class_constant_for_sti
    cond_a = Caboose::EZ::Condition.new
    cond_a << Article
        
    expected = ["articles.type = ?", "Article"]
    assert_equal expected, cond_a.to_sql
    
    cond = Caboose::EZ::Condition.new
    cond << Article.find(1)
    
    expected = ["articles.id = ?", 1]    
    assert_equal expected, cond.to_sql    
  end
  
  def test_soundex_clause
    cond = Caboose::EZ::Condition.new :my_table, :inner => :or
    cond.name % '%fab%'    
    expected = ["my_table.name SOUNDS LIKE ?", "%fab%"]
    assert_equal expected, cond.to_sql
  end
  
  def test_conditions_from_params_and_example  
    params = { 'title' => 'package', 'body' => nil, 'author' => 'Fab' }
    
    articles = Article.ez_find(:all, :include => :author) do |article, author|
      article.title   =~ "%#{params['title']}%"
      article.body    =~ "%#{params['body']}%" 
      author.name     == params['author'] 
    end   
    assert_equal 1, articles.length
    
    params = { 'title' => nil, 'body' => nil, 'author' => nil }
    
    articles = Article.ez_find(:all, :include => :author) do |article, author|
      article.title   =~ "%#{params['title']}%"
      article.body    =~ "%#{params['body']}%"
      author.name     == params['author']
    end   
    assert_equal Article.ez_find(:all).length, articles.length    
  end
  
  def test_conditions_from_params_or_example
    params = { 'term' => 'package', 'author' => 'Fab' }
    
    articles = Article.ez_find(:all, :include => :author) do |article, author|
      unless params['term'].nil?
        article.any do
          title   =~ "%#{params['term']}%"
          body    =~ "%#{params['term']}%"
        end
      end
      author.name == params['author']
    end   
    
    assert_equal 1, articles.length
  end
  
  def test_create_clause
    cond = Caboose::EZ::Condition.new :my_table
    cond.create_clause(:foo, :=~, '%bar%')
    cond.create_clause(:biz, '==', 'baz')
    cond.create_clause(:case, :==, 'insensitive', true)
    expected = ["my_table.foo LIKE ? AND my_table.biz = ? AND UPPER(my_table.case) = ?", "%bar%", "baz", "INSENSITIVE"]
    assert_equal expected, cond.to_sql
  end
  
  def test_with_conditional_clauses
    fi_facility_id = 1
    fi_client_id = 2
    fi_case_manager_id = 3
    fi_accepted = true
    fi_pltype = nil    
    
    expected = ["placements.facility_id = ? AND placements.client_id = ? AND placements.case_manager_id = ? AND placements.accepted = ?", 1, 2, 3, true]
    
    cond = Caboose::EZ::Condition.new :placements
    cond.clause(:facility_id) == fi_facility_id 
    cond.clause(:client_id) == fi_client_id 
    cond.clause(:case_manager_id) == fi_case_manager_id
    cond.clause(:accepted) == fi_accepted 
    cond.clause(:pltype) == fi_pltype 
    assert_equal expected, cond.to_sql
    
    # note: because of the lexical variable scope for block vars, you explicitly should have them set (nil is fine) outside the block
    # or else the block can't access them and gives 'undefined local variable or method'
    cond = Caboose::EZ::Condition.new :table_name => :placements do
      facility_id == fi_facility_id 
      client_id == fi_client_id    
      case_manager_id == fi_case_manager_id   
      accepted == fi_accepted                  
      pltype == fi_pltype                      
    end
    assert_equal expected, cond.to_sql  
  end
  
  def test_create_clause_from_map
    params = { :name => 'test', :price => 20, :postcode => 'BC234' }    
    
    map = { :price => :>, :postcode => :=~ }
    map.default = :==
  
    cond = Caboose::EZ::Condition.new :my_table
    params.sort { |a, b| a.to_s <=> b.to_s }.each do |k,v|
      cond.create_clause(k, map[k], v)
    end
    expected = ["my_table.name = ? AND my_table.postcode LIKE ? AND my_table.price > ?", "test", "BC234", 20]
    assert_equal expected, cond.to_sql
  end
  
  def test_multi_clause
    expected = ["(my_table.title LIKE ? OR my_table.subtitle LIKE ? OR my_table.body LIKE ? OR my_table.footnotes LIKE ? OR my_table.keywords LIKE ?)", "%package%", "%package%", "%package%", "%package%", "%package%"]
    
    multi = Caboose::EZ::MultiClause.new([:title, :subtitle, :body, :footnotes, :keywords], :my_table)
    multi =~ '%package%'    
    assert_equal expected, multi.to_sql
   
    cond = Caboose::EZ::Condition.new :my_table
    cond.any_of(:title, :subtitle, :body, :footnotes, :keywords) =~ '%package%'
    
    assert_equal expected, cond.to_sql
    
    cond = Caboose::EZ::Condition.new :my_table
    cond.any_of(:title, :subtitle, :body, :footnotes, :keywords) =~ '%package%'
    cond.all_of(:active, :flagged) == true
       
    expected = ["(my_table.title LIKE ? OR my_table.subtitle LIKE ? OR my_table.body LIKE ? OR my_table.footnotes LIKE ? OR my_table.keywords LIKE ?) AND (my_table.active = ? AND my_table.flagged = ?)", "%package%", "%package%", "%package%", "%package%", "%package%", true, true]
    assert_equal expected, cond.to_sql 
    
    expected = ["(my_table.title LIKE ? OR my_table.subtitle LIKE ? OR my_table.body LIKE ? OR my_table.footnotes LIKE ? OR my_table.keywords LIKE ?) OR (my_table.active = ? AND my_table.flagged = ?)", "%package%", "%package%", "%package%", "%package%", "%package%", true, true]
    assert_equal expected, cond.to_sql(:or) 
  end
  
  def test_multi_clause_ez_where
    articles = Article.ez_find(:all) do |article|
      article.any_of(:title, :body) =~ '%package%'
      article.all_of(:title, :body) =~ '%the%'
    end   
    assert_equal 1, articles.length
  end
  
  def test_sql_in_statement_and_any_of_all_of
    cond = Caboose::EZ::Condition.new :my_table
    cond.foo === ['bar', 'baz', 'buzz']
    cond.any_of(:created_by, :updated_by, :reviewed_by) == 2
    cond.all_of(:active, :flagged) == true
    cond.comments_count <=> [10, 15]
    expected = ["my_table.foo IN (?) AND (my_table.created_by = ? OR my_table.updated_by = ? OR my_table.reviewed_by = ?) AND (my_table.active = ? AND my_table.flagged = ?) AND my_table.comments_count BETWEEN ? AND ?", ["bar", "baz", "buzz"], 2, 2, 2, true, true, 10, 15]
    assert_equal expected, cond.to_sql
  end
  
  def test_case_insensitive_conditions
    cond = Caboose::EZ::Condition.new :table_name => :my_table, :inner => :or
    cond.name.nocase =~ '%fab%'
    cond.name.upcase =~ '%fab%' # also: downcase ...yeah yeah... 
    cond.name.case_insensitive == 'foo'
    expected = ["UPPER(my_table.name) LIKE ? OR UPPER(my_table.name) LIKE ? OR UPPER(my_table.name) = ?", "%FAB%", "%FAB%", "FOO"]
    assert_equal expected, cond.to_sql
    
    cond = Caboose::EZ::Condition.new :my_table do 
      foo.nocase == 'bar'
    end
    expected = ["UPPER(my_table.foo) = ?", "BAR"]
    assert_equal expected, cond.to_sql    
  end
  
  def test_case_insensitive_multi_clause
    cond = Caboose::EZ::Condition.new :my_table
    cond.any_of(:title, :subtitle, :body, :footnotes, :keywords).nocase =~ '%package%'
    expected = ["(UPPER(my_table.title) LIKE ? OR UPPER(my_table.subtitle) LIKE ? OR UPPER(my_table.body) LIKE ? OR UPPER(my_table.footnotes) LIKE ? OR UPPER(my_table.keywords) LIKE ?)", "%PACKAGE%", "%PACKAGE%", "%PACKAGE%", "%PACKAGE%", "%PACKAGE%"]
    assert_equal expected, cond.to_sql
  end
  
  def test_handling_of_empty_clause_values
    clause = Caboose::EZ::Clause.new(:name)
    clause == nil    
    assert clause.empty?
    
    clause = Caboose::EZ::Clause.new(:name)
    clause == ''    
    assert clause.empty?
    
    clause = Caboose::EZ::Clause.new(:name)
    clause =~ '%'    
    assert clause.empty?
    
    clause = Caboose::EZ::Clause.new(:name)
    clause =~ '%%'    
    assert clause.empty?
    
    clause = Caboose::EZ::Clause.new(:value)
    clause == false  
    assert !clause.empty? # NOT empty
    
    clause = Caboose::EZ::SqlClause.new('')  
    assert clause.empty?
    
    clause = Caboose::EZ::SqlClause.new(nil)  
    assert clause.empty?
    
    clause = Caboose::EZ::ArrayClause.new(['name = ?', ''])  
    assert clause.empty?
    
    clause = Caboose::EZ::ArrayClause.new(['name = ?', nil])  
    assert clause.empty?
    
    clause = Caboose::EZ::ArrayClause.new(['id = 1'])  
    assert !clause.empty? # NOT empty
    
    clause = Caboose::EZ::ArrayClause.new(['name = ?', false])  
    assert !clause.empty? # NOT empty
    
    multi = Caboose::EZ::MultiClause.new([:title, :subtitle, :body, :footnotes, :keywords], :my_table)
    multi == nil
    assert multi.empty?
    
    multi = Caboose::EZ::MultiClause.new([:title, :subtitle, :body, :footnotes, :keywords], :my_table)
    multi =~ '%%'
    assert multi.empty? 
    
    multi = Caboose::EZ::MultiClause.new([:title, :subtitle, :body, :footnotes, :keywords], :my_table)
    multi == false
    assert !multi.empty? # NOT empty 
  end
  
  def test_empty_clause_values_in_complex_block
    cond = Caboose::EZ::Condition.new :my_table do
      any { name == nil; name =~ '%' }
      all { occupation == nil; country == '' }     
    end
    cond << ['country = ?', '']
    cond << ''
    cond << false
    assert_nil cond.to_sql    
  end
     
end