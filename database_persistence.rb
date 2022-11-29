require "pg"

class DatabasePersistence
  def initialize
    @db = PG.connect(dbname: "todos")
  end

  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = @db.exec_params(sql, [id])
  
    tuple = result.first

    list_id = tuple["id"].to_i
    todos = find_todos_for_list(list_id)
    {id: list_id, name: tuple["name"], todos: todos}
  end

  def all_lists
    sql = "SELECT * FROM lists"
    result = @db.exec(sql)
  
    result.map do |tuple|
      list_id = tuple["id"].to_i
      todos = find_todos_for_list(list_id)
      {id: list_id, name: tuple["name"], todos: todos}
    end
  end

  def create_new_list(list_name)
    sql = "INSERT INTO lists (name) VALUES ($1)"
    @db.exec_params(sql, [list_name])
  end

  def delete_list(id)
    @db.exec_params("DELETE FROM todos WHERE list_id = $1", [id])
    @db.exec_params("DELETE FROM lists WHERE id = $1", [id])      
  end

  def update_list_name(id, new_name)
    sql = "UPDATE lists SET name = $1 WHERE id = $2"
    @db.exec_params(sql, [new_name, id])
  end

  def create_new_todo(list_id, todo_name)
    sql = "INSERT INTO todos (list_id, name) VALUES ($1, $2)"
    @db.exec_params(sql, [list_id, todo_name])
  end

  def delete_todo_from_list(list_id, todo_id)
    sql = "DELETE FROM todos WHERE id = $1 AND list_id = $2"
    @db.exec_params(sql, [todo_id, list_id])
  end

  def update_todo_status(list_id, todo_id, new_status)
    sql = "UPDATE todos SET completed = $1 WHERE id = $2 AND list_id = $3"
    @db.exec_params(sql, [new_status, todo_id, list_id])
  end

  def mark_all_todos_as_completed(list_id)
    sql = "UPDATE todos SET completed = true WHERE list_id = $1"
    @db.exec_params(sql, [list_id])
  end

  private

  def find_todos_for_list(list_id)
    todo_sql = "SELECT * FROM todos WHERE list_id = $1"
    todos_result = @db.exec_params(todo_sql, [list_id])

    todos_result.map do |todo_tuple|
      {id: todo_tuple["id"].to_i,
      name: todo_tuple["name"],
      completed: todo_tuple["completed"] == "t"}
    end
  end
end