let data;


window.addEventListener('message', function (event) {
  data = event.data;
  switch (event.data.action) {
    case 'open-lb':
      UpdateLeaderboard(event.data);

      $('#leaderboard-container').fadeIn();
      break;

    case 'update-lb':
      UpdateLeaderboard(event.data);
      break;

    case 'hide-lb':
      $('#leaderboard-container').fadeOut();
      break;
  }


});

function UpdateLeaderboard(data) {
  let i = 0;
  let html = '';
  for (const steam in data.leaderboard) {
    i += 1;

    let id = '';

    let targetPlayer = data[steam];

    switch (i) {
      case 1: id = 'first';
        break;
      case 2: id = 'second';
        break;
      case 3: id = 'third';
        break;
    }

    html += `<div class="item" id="${id}">
    <div class="position">
      <div class="de-rotate"><i class="fas fa-trophy"></i>
      </div>
    </div>
    <div class="player-name" level='2'>${(targetPlayer && targetPlayer.name) ?? 'Not A Player'}</div>
    <div class="player-kills">${(targetPlayer && targetPlayer.allKills) ?? 0} KILLS</div>
    <div class="player-level">LEVEL ${(targetPlayer && targetPlayer.currentLevel) ?? '*'}</div>
  </div>`

    if (i == 3) {
      break;
    }

  }


  let mePlayer = data.myindex;

  html += `<div class="item" id="mydata">
  <div class="position">
    <div class="de-rotate"><i class="fas fa-trophy"></i>
    </div>
  </div>
  <div class="player-name" level='2'>${mePlayer.name}</div>
  <div class="player-kills">${mePlayer.allKills ?? 0} KILLS</div>
  <div class="player-level">LEVEL ${mePlayer.currentLevel}</div>
</div>`

  $('#leaderboard-container').html(html);
}

document.onkeyup = function (event) {
  if (event.key == 'Escape') {
    closeMenu()
  }
}

closeMenu = function () {
  if (!inMenu) return;
  $('#body').fadeOut()
  $.post('https://fGangwars/closeMenu', JSON.stringify({})); //Close NUI and reload page
  setTimeout(function () {
    window.location.reload()
  }, 500);
}