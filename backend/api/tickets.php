<?php

header("Content-Type: application/json");

$data=[];

for($i=1;$i<=15;$i++){

$data[]=[

"id"=>$i,

"title"=>"Ticket ".$i,

"description"=>"Deskripsi Ticket ".$i,

"priority"=>"High",

"status"=>"Open"

];

}

echo json_encode([

"success"=>true,

"data"=>$data

]);