<?php

header("Content-Type: application/json");

$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

$users = [

[
"id"=>1,
"name"=>"Admin",
"email"=>"msury@gmail.com",
"password"=>"suryagantengdewe",
"role"=>"admin"
],

[
"id"=>2,
"name"=>"Helpdesk",
"email"=>"helpdesk@gmail.com",
"password"=>"suryagantengdewe",
"role"=>"helpdesk"
],

[
"id"=>3,
"name"=>"User",
"email"=>"user@gmail.com",
"password"=>"suryagantengdewe",
"role"=>"user"
]

];

foreach($users as $user){

if($user['email']==$email && $user['password']==$password){

unset($user['password']);

echo json_encode([

"success"=>true,
"user"=>$user

]);

exit;

}

}

echo json_encode([
"success"=>false,
"message"=>"Login gagal"
]);