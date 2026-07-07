<?php

header("Content-Type: application/json");

$id=$_GET['id']??1;

echo json_encode([

"success"=>true,

"data"=>[

"id"=>$id,

"title"=>"Ticket ".$id,

"description"=>"Detail ticket ".$id,

"priority"=>"High",

"status"=>"Open"

]

]);