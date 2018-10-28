exception Undefined_variable of string

type 'a env_body = {var: string; value: 'a; next: 'a env}
 and 'a env =
   | EmptyEnv
   | Binding of 'a env_body

let rec apply_env(env, search_var) =
  match env with
  | EmptyEnv -> raise (Undefined_variable search_var)
  | Binding {var = var; value = value; next = inner_env} ->
     if var = search_var then value
     else apply_env(inner_env, search_var)

let update_env(env, var, value) =
  Binding {var = var; value = value; next = env}
