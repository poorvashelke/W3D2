require 'sqlite3'
require 'singleton'

class PlayDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Users
  attr_accessor :id, :fname, :lname

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_id(id)
    use_hash = PlayDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
  return nil unless use_hash.length > 0  
  Users.new(use_hash.first)
  end
  def self.find_by_names(fname, lname)
    use_hash = PlayDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ?
      AND
        lname = ?
  SQL
return nil unless use_hash.length > 0  
Users.new(use_hash.first)
  end

  def authored_questions
    Questions.find_by_author_id(id)  
  end
  def authored_replies
    Replies.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end
end

class Questions
    attr_accessor :id, :title, :body, :author_id
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def self.find_by_id(id)
      use_hash = PlayDBConnection.instance.execute(<<-SQL, id)
        SELECT
          *
        FROM
          questions
        WHERE
          id = ?
      SQL
    return nil unless use_hash.length > 0  
    Questions.new(use_hash.first)
  end

  def self.find_by_author_id(author_id)
    use_hash = PlayDBConnection.instance.execute(<<-SQL, author_id)
        SELECT
          *
        FROM
          questions
        WHERE
          author_id = ?
      SQL
    return nil unless use_hash.length > 0  
    Questions.new(use_hash.first)
  end

  def author
    Users.find_by_id(author_id)
  end
  def replies
    Replies.find_by_question_id(id)
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
end

class QuestionFollow
    attr_accessor :question_id, :user_id
  def initialize(options)
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

def self.find_by_id(id)
    use_hash = PlayDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
  return nil unless use_hash.length > 0  
  QuestionFollow.new(use_hash.first)
  end

  def self.followers_for_question_id(question_id)
    use_hash = PlayDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        user_id
      FROM 
        question_follows
      WHERE
        question_id = ?
    SQL
  use_hash.map {|hash| Users.find_by_id(hash['user_id'])}
  end

  def self.followed_questions_for_user_id(user_id)
    use_hash = PlayDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        question_id
      FROM 
        question_follows
      WHERE
        user_id = ?
    SQL
  use_hash.map {|hash| Questions.find_by_id(hash['question_id'])}
  end

  def self.most_followed_questions(numb)
    use_hash = PlayDBConnection.instance.execute(<<-SQL, numb)
      SELECT
        question_id
      FROM
        question_follows
      GROUP BY
        question_id
      ORDER BY
        COUNT(user_id) 
      DESC
      LIMIT
        ?
    SQL
      use_hash.map {|hash| Questions.find_by_id(hash['question_id'])}
  end

end

class Replies
    attr_accessor :id, :question_id, :reply_id, :user_id, :body
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @reply_id = options['reply_id']
    @user_id = options['user_id']
    @body = options['body']
  end

def self.find_by_id(id)
    use_hash = PlayDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
  return nil unless use_hash.length > 0  
  Replies.new(use_hash.first)
  end
  
  def self.find_by_user_id(user_id)
    use_hash = PlayDBConnection.instance.execute(<<-SQL, user_id)
        SELECT
          *
        FROM
          replies
        WHERE
          user_id = ?
      SQL
    return nil unless use_hash.length > 0  
    Replies.new(use_hash.first)
  end
  
  def self.find_by_question_id(question_id)
    use_hash = PlayDBConnection.instance.execute(<<-SQL, question_id)
        SELECT
          *
        FROM
          replies
        WHERE
          question_id = ?
      SQL
    return nil unless use_hash.length > 0  
    use_hash.map {|hash| Replies.new(hash)}
  end

  def author
    Users.find_by_id(user_id)
  end
  def question
    Questions.find_by_id(question_id)
  end
  def parent_reply
    Replies.find_by_id(reply_id)
  end
  def child_replies
    id = self.id
    use_hash = PlayDBConnection.instance.execute(<<-SQL, id)
        SELECT
          *
        FROM
          replies
        WHERE
          reply_id = ?
      SQL
    return nil unless use_hash.length > 0  
    Replies.new(use_hash.first)
  end

end

class Question_likes
    attr_accessor :question_id, :user_id
  def initialize(options)
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

def self.find_by_id(id)
    use_hash = PlayDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
  return nil unless use_hash.length > 0  
  Question_likes.new(use_hash.first)
  end
end