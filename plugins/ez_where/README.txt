Copyright (c) 2006 Ezra Zygmuntowicz & Fabien Franzen
  
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Welcome to the new improved ez_where plugin for rails. This plugin is meant 
to be used as a nice ruby like syntax for creating the :conditions part of an 
ActiveRecord::Base.find. We also add the ActiveRecord::Base.ez_find method.
This method takes a block to simplify single and multi table queries.

articles = Article.ez_find(:all, :include => :author) do |article, author|
  article.title =~ "%Foo Title%"
  author.any do
    name == 'Ezra'
    name == 'Fab'
  end 
end

This will produce :conditions => ["article.title LIKE ? AND 
                   (authors.name = ? OR authors.name = ?)",
                   "%Foo Title%", "Ezra", "Fab"]

Basically here is the breakdown of how we map ruby operators 
to SQL operators:

foo == 'bar'           #=> ["foo = ?", 'bar']
foo =~ '%bar'          #=> ["foo LIKE ?", '%bar']
foo <=> (1..5)         #=> ["foo BETWEEN ? AND ?", 1, 5]
id === [1, 2, 3, 5, 8] #=> ["id IN(?)", [1, 2, 3, 5, 8]]
<, >, >=, <= et all will just work like you expect.

There is also the ability to create the conditions in stages so 
you can build up a query:

cond = Caboose::EZ::Condition.new do
  foo == 'bar'
  baz <=> (1..5)
  id === [1, 2, 3, 5, 8]
end
 
@result = Model.find(:all, :conditions=> cond.to_sql)
#=> ["foo = ? AND baz BETWEEN ? AND ? AND id IN (?)",
     "bar", 1, 5, [1, 2, 3, 5, 8]]

You can even do nested sub conditions. condition will use AND 
by default in the sub condition:

cond = Caboose::EZ::Condition.new :my_table do
  foo == 'bar'
  baz <=> (1..5)
  id === [1, 2, 3, 5, 8]
  condition :my_other_table do
    fiz =~ '%faz%'
  end
end

@result = Model.find(:all, :conditions=> cond.to_sql)
#=> ["my_table.foo = ? AND my_table.baz BETWEEN ? AND ? 
     AND my_table.id IN (?) AND (my_other_table.fiz LIKE ?)",
     "bar", 1, 5, [1, 2, 3, 5, 8], "%faz%"]

You can also build multiple Condition objects and join
them together for one monster find:

cond_a = Caboose::EZ::Condition.new :my_table do
  foo == 'bar'
  condition :my_other_table do
    id === [1, 3, 8]
    foo == 'other bar'
    fiz =~ '%faz%'
  end
end
#=> ["my_table.foo = ? AND (my_other_table.id IN (?) AND my_other_table.foo = ?
       AND my_other_table.fiz LIKE ?)", "bar", [1, 3, 8], "other bar", "%faz%"]

cond_b = Caboose::EZ::Condition.new :my_table do
  active == true
  archived == false
end

#=> ["my_table.active = ? AND my_table.archived = ?", true, false]

composed_cond = Caboose::EZ::Condition.new
composed_cond << cond_a
composed_cond << cond_b
composed_cond << 'fuzz IS NULL'

@result = Model.find(:all, :conditions => composed_cond.to_sql)
#=> ["(my_table.foo = ? AND (my_other_table.id IN (?) AND my_other_table.foo = ? 
      AND my_other_table.fiz LIKE ?)) AND (my_table.active = ? AND my_table.archived = ?)
      AND fuzz IS NULL", "bar", [1, 3, 8], "other bar", "%faz%", true, false]   

You can compose a new condition from different sources:

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
# a regular Hash
cond.append :ruby => 1, :php => 0

#(append is aliased to << because of syntax issues 
involving multiple args like :or)

@result = Model.find(:all, :conditions=> cond.to_sql)

#=> ["(my_table.foo = ? AND my_table.baz = ?) OR (baz = ? AND bar IS NOT NULL) 
      AND biz IS NULL AND authors.id = ? AND (php = ? AND ruby = ?)", "bar", "buzz", "fuzz", 1, 0, 1]

OK there is also other options for doing subconditions. OR is 
aliased to any and any creates a subcondition that uses OR to 
join the sub conditions:

cond = Caboose::EZ::Condition.new :my_table do
  foo == 'bar'
  any :my_other_table do
    baz === ['fizz', 'fuzz']
    biz == 'boz'
  end
end

@result = Model.find(:all, :conditions=> cond.to_sql)

#=> ["my_table.foo = ? AND (my_other_table.baz IN (?) 
     OR my_other_table.biz = ?)",
     "bar", ["fizz", "fuzz"], "boz"]

OK lets look a bit more at ez_find with a few more complex queries:

# all articles written by Ezra. Here you can use a normal AR object
# in the conditions
# session[:user_id] = 2
ezra = Author.find(session[:user_id])    
@articles = Article.ez_find(:all, :include => :author) do |article, author|
  author << ezra # use AR instance to add condition; uses PK value if set: author.id = ezra.id
end 
#=>["(authors.id = ?)", 2]

# all articles written by Ezra, where he himself responds in comments
@articles = Article.ez_find(:all, :include => [:author, :comments]) do |article, author, comment|
  article.author_id == ezra.id
  comment.author_id == ezra.id   
end
#=>["(articles.author_id = ?) AND (comments.author_id = ?)", 2, 2]

# any articles written by Fab or Ezra
@articles = Article.ez_find(:all, :include => :author) do |article, author|
  author.name === ['Fab', 'Ezra']   
end
#=>["(authors.name IN (?))", ["Fab", "Ezra"]]

# any articles written by Fab or Ezra, using subcondition
@articles = Article.ez_find(:all, :include => :author) do |article, author|
  author.any do
    name == 'Ezra'
    name == 'Fab'
  end  
end
#=>["(authors.name = ? OR authors.name = ?)", "Ezra", "Fab"]

# any articles written by or commented on by Fab, using subcondition
@articles = Article.ez_find(:all, :include => [:author, :comments]) do |article, author, comment|
  article.sub { author_id == 1 }
  comment.outer = :or # set :outer for the comment condition, since it defaults to :and
  comment.sub { author_id == 1 }       
end
#=>["(articles.author_id = ?) OR (comments.author_id = ?)", 1, 1]

@articles = Article.ez_find(:all, :include => [:author, :comments],
                           :outer => { :comments => :or }, 
                           :inner => { :article => :or}) do |article, author, comment|
  article.sub { author_id == 1; author_id == 2 }
  comment.sub { author_id == 1 } 
end
["(articles.author_id = ? OR articles.author_id = ?) OR (comments.author_id = ?)", 1, 2, 1]

And finally you can use any and all with ez_condition like this:

cond = Article.ez_condition { active == true; archived == false }
cond.all { body =~ '%intro%'; body =~ '%demo%' }
cond.any { title =~ '%article%'; title =~ '%first%' }

#=>  ["articles.active = ? AND articles.archived = ? 
      AND (articles.body LIKE ? AND articles.body LIKE ?) 
      AND (articles.title LIKE ? OR articles.title LIKE ?)",
      true, false, "%intro%", "%demo%", "%article%", "%first%"]


As you can see we can get quite detailed in the queries this can create. Just use your imagination ;-)
Also the test cases in the plugin source have many more examples to choose from.

Get it here: http://opensvn.csie.org/ezra/rails/plugins/dev/ez_where/