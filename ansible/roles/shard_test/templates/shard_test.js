
var people = ["Marc", "Bill", "George", "Eliot", "Matt", "Trey", "Tracy", "Greg", "Steve", "Kristina", "Katie", "Jeff"];
for (var i = 0; i < 5000; i ++ ) {
  var name = people[Math.floor(Math.random()*people.length)],
      age = Math.floor(Math.random()*100);

  db.user.save({ _id: i, name: name, age : age });
}

var messages = ["Hello there", "Good Morning", "valar morghulis"];
var createTime = new Date();
for (var j = 0; j < 5000; j ++) {
  createTime.setYear(Math.floor(Math.random()*3000));
  db.messages.save({
    userid: Math.floor(Math.random()*5000),
    message: messages[Math.floor(Math.random()*messages.length)],
    createTime: createTime
  })
}

db.messages.ensureIndex({createTime: 1});

// db.messages.find({createTime: { $lt: ISODate("1972-01-05T11:02:59.652Z")}})