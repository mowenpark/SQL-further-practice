require 'singleton'
require 'sqlite3'

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
  
end

class Questions
end

class QuestionFollows
end

class Replies
end

class QuestionLikes
end
