require 'singleton'
require 'sqlite3'
require 'byebug'

# Handles the connection to the database, singleton makes sure there is only
# one connection.
class QuestionsDatabase < SQLite3::Database

  include Singleton

  def initialize
    super ('questions.db')

    self.results_as_hash = true
    self.type_translation = true

  end
end

class Users
  def self.find_by_id(id)
      data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM users WHERE id = '#{id}'
      SQL
      return nil if data.empty?
      Users.new(data[0])
  end

  attr_accessor :fname, :lname, :id

  def initialize(options)
    @id, @fname, @lname = options.values_at('id', 'fname', 'lname')
  end

  def self.find_by_name(fname, lname)
    QuestionsDatabase.instance.execute(<<-SQL)
    SELECT * FROM users WHERE fname = '#{fname}' AND lname = '#{lname}'
    SQL
  end

  def authored_questions
    Questions.find_by_author_id(@id)
  end

  def authored_replies
    Replies.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollows.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLikes.liked_questions_for_user_id(@id)
  end

end

class Questions
  def self.find_by_id(id)
      data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM questions WHERE id = '#{id}'
      SQL
      return nil if data.empty?
      Questions.new(data[0])
  end

  def self.most_followed(n)
    QuestionFollows.most_followed_questions(n)
  end

  attr_accessor :title, :body, :id, :author_id

  def initialize(options)
    @id, @title, @body, @author_id = options.values_at('id', 'title', 'body', 'author_id')
  end

  def self.find_by_author_id(author)
    QuestionsDatabase.instance.execute(<<-SQL)
    SELECT * FROM questions WHERE author_id = '#{author}'
    SQL
  end

  def author
    @author_id
  end

  def replies
    Replies.find_by_question_id(@id)
  end

  def followers
    QuestionFollows.followers_for_question_id(@id)
  end

  def likers
    QuestionLikes.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLikes.num_likes_for_question_id(@id)
  end

end

class QuestionFollows
  def self.find_by_id(id_num)
      data = QuestionsDatabase.instance.execute(<<-SQL, id_num:id_num)
      SELECT * FROM question_follows WHERE id = :id_num
      SQL
      return nil if data.empty?
      QuestionFollows.new(data[0])
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
    question_follows.questions_id, COUNT(*)
    FROM
    question_follows
    GROUP BY
    question_follows.questions_id
    ORDER BY
    COUNT(*) DESC
    SQL
    data[0...n]
  end


  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      users.id
    FROM
      users
    JOIN
    question_follows ON users.id = question_follows.users_id
    WHERE
    question_follows.questions_id = '#{question_id}'
    SQL
    # debugger
    data.map { |datum| Users.find_by_id( datum['id'] ) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      question_follows.questions_id
    FROM
      question_follows
    JOIN
    users ON users.id = question_follows.users_id
    WHERE
    question_follows.users_id = '#{user_id}'
    SQL
    # debugger
    data.map { |datum| Questions.find_by_id( datum['questions_id'] ) }
  end

  attr_accessor :questions_id, :users_id, :id

  def initialize(options)
    @id, @questions_id, @users_id = options.values_at('id', 'questions_id', 'users_id')
  end
end

class Replies
  def self.find_by_id(id)
      data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM replies WHERE id = '#{id}'
      SQL
      return nil if data.empty?
      Replies.new(data[0])
  end

  attr_accessor :id, :questions_id, :parent_id, :user_id, :body

  def initialize(options)
    @id, @questions_id, @parent_id, @user_id, @body = options.values_at('id', 'questions_id', 'parent_id', 'user_id', 'body')
  end

  def self.find_by_user_id(user)
    QuestionsDatabase.instance.execute(<<-SQL)
    SELECT * FROM replies WHERE user_id = '#{user}'
    SQL
  end

  def self.find_by_question_id(question_id)
    QuestionsDatabase.instance.execute(<<-SQL)
    SELECT * FROM replies WHERE questions_id = '#{question_id}'
    SQL
  end

  def author
    @user_id
  end

  def question
    @questions_id
  end

  def parent_reply
    @parent_id
  end

  def child_replies
    QuestionsDatabase.instance.execute(<<-SQL)
    SELECT * FROM replies WHERE parent_id = '#{@id}'
    SQL
  end

end

class QuestionLikes
  def self.find_by_id(id)
      data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM question_likes WHERE id = '#{id}'
      SQL
      return nil if data.empty?
      QuestionLikes.new(data[0])
  end

  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id:question_id)
    SELECT question_likes.user_id
    FROM question_likes
    WHERE question_likes.question_id = :question_id
    SQL
    # debugger
    data.map { |datum| Users.find_by_id(datum["user_id"]) }
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id:question_id)
    SELECT
    COUNT(*)
    FROM
    question_likes
    WHERE question_id = :question_id
    SQL
    data[0]["COUNT(*)"]
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id:user_id)
    SELECT
    question_id
    FROM
    question_likes
    WHERE user_id = :user_id
    SQL
    data.map { |datum| Questions.find_by_id(datum["question_id"]) }
  end

  attr_accessor :id, :upvote, :question_id, :user_id

  def initialize(options)
    @id, @upvote, @question_id, @user_id = options.values_at('id', 'upvote', 'question_id', 'user_id')
  end
end
