<!DOCTYPE html>
<html lang="hu">
<head>
  <meta charset="UTF-8">
  <title>3D hatású Autós Szlalom Játék (Canvas)</title>
  <style>
    body {
      margin: 0;
      overflow: hidden;
      background: #000;
      color: #fff;
      font-family: Arial, sans-serif;
    }
    #gameCanvas {
      display: block;
      margin: 0 auto;
      background: #2d2d2d;
      border: 2px solid white;
    }
    #hud {
      position: absolute;
      top: 10px;
      left: 10px;
      font-size: 18px;
      background: rgba(0,0,0,0.5);
      padding: 5px 10px;
      border-radius: 5px;
    }
    #modeDisplay {
      position: absolute;
      top: 10px;
      right: 10px;
      font-size: 18px;
      background: rgba(0,0,0,0.5);
      padding: 5px 10px;
      border-radius: 5px;
    }
    #scoreDisplay {
      position: absolute;
      bottom: 10px;
      right: 10px;
      font-size: 18px;
      background: rgba(0,0,0,0.5);
      padding: 5px 10px;
      border-radius: 5px;
    }
  </style>
</head>
<body>
  <canvas id="gameCanvas" width="400" height="600"></canvas>
  <div id="hud">Sebesség: 0</div>
  <div id="modeDisplay">Mód: Normál</div>
  <div id="scoreDisplay">Pontszám: 0</div>

  <script>
    const canvas = document.getElementById('gameCanvas');
    const ctx = canvas.getContext('2d');
    const hud = document.getElementById('hud');
    const modeDisplay = document.getElementById('modeDisplay');
    const scoreDisplay = document.getElementById('scoreDisplay');

    const canvasWidth = canvas.width;
    const canvasHeight = canvas.height;

    // Autó adatok
    let carWidth = 40;
    let carHeight = 80;
    let carX = (canvasWidth - carWidth) / 2;
    let carY = canvasHeight - carHeight - 20;

    // Mozgás bemenet
    let moveLeft = false;
    let moveRight = false;

    // Sebesség módok
    let isSport = false;
    const minSpeed = 2;
    const maxSpeed = 15;
    let speed = 4;

    // Pontszám
    let score = 0;

    // Útvonal-vonalak
    let roadLines = [];
    const lineCount = 10;
    const lineHeight = 40;
    const lineGap = 60;

    // Akadályok
    let obstacles = [];

    function init() {
      // vonalak
      for (let i = 0; i < lineCount; i++) {
        roadLines.push({
          x: canvasWidth/2 - 5,
          y: i * (lineHeight + lineGap),
          width: 10,
          height: lineHeight
        });
      }

      // input
      window.addEventListener('keydown', (e) => {
        if (e.key === 'ArrowLeft') moveLeft = true;
        if (e.key === 'ArrowRight') moveRight = true;
        if (e.key === ' ') {
          isSport = !isSport;
          modeDisplay.textContent = 'Mód: ' + (isSport ? 'Sport' : 'Normál');
        }
        if (e.key === 'ArrowUp') {
          speed = Math.min(speed + 1, maxSpeed);
        }
        if (e.key === 'ArrowDown') {
          speed = Math.max(speed - 1, minSpeed);
        }
      });
      window.addEventListener('keyup', (e) => {
        if (e.key === 'ArrowLeft') moveLeft = false;
        if (e.key === 'ArrowRight') moveRight = false;
      });

      // akadályok
      setInterval(() => {
        spawnObstacle();
      }, 1500);

      requestAnimationFrame(gameLoop);
    }

    function spawnObstacle() {
      const obsWidth = 30;
      const obsHeight = 30;
      const obsX = Math.random() * (canvasWidth - obsWidth);
      const obsY = -obsHeight;
      obstacles.push({ x: obsX, y: obsY, width: obsWidth, height: obsHeight });
    }

    function gameLoop() {
      // sebesség kijelzés
      hud.textContent = 'Sebesség: ' + speed;

      // pontszám növelés
      score += 1;
      scoreDisplay.textContent = 'Pontszám: ' + score;

      // mozgatás
      if (moveLeft) carX -= 5;
      if (moveRight) carX += 5;
      if (carX < 0) carX = 0;
      if (carX + carWidth > canvasWidth) carX = canvasWidth - carWidth;

      for (let line of roadLines) {
        line.y += speed;
        if (line.y > canvasHeight) {
          line.y = - line.height;
        }
      }

      // akadályok frissítés
      for (let i = obstacles.length - 1; i >= 0; i--) {
        const obs = obstacles[i];
        obs.y += speed;

        if (rectIntersect(obs, { x: carX, y: carY, width: carWidth, height: carHeight })) {
          alert('Ütköztél! Pontszámod: ' + score);
          window.location.reload();
          return;
        }

        if (obs.y > canvasHeight) {
          obstacles.splice(i, 1);
        }
      }

      draw();

      requestAnimationFrame(gameLoop);
    }

    function draw() {
      ctx.fillStyle = '#2d2d2d';
      ctx.fillRect(0, 0, canvasWidth, canvasHeight);

      // oldalsó szegélyek
      ctx.fillStyle = '#444';
      const roadMargin = 40;
      ctx.fillRect(0, 0, roadMargin, canvasHeight);
      ctx.fillRect(canvasWidth - roadMargin, 0, roadMargin, canvasHeight);

      // középvonalak
      ctx.fillStyle = 'white';
      for (let line of roadLines) {
        ctx.fillRect(line.x, line.y, line.width, line.height);
      }

      // akadályok
      ctx.fillStyle = 'yellow';
      for (let obs of obstacles) {
        ctx.beginPath();
        ctx.arc(obs.x + obs.width/2, obs.y + obs.height/2, obs.width/2, 0, Math.PI * 2);
        ctx.fill();
      }

      // autó
      ctx.fillStyle = 'red';
      ctx.fillRect(carX, carY, carWidth, carHeight);
    }

    function rectIntersect(a, b) {
      return !(
        a.x + a.width < b.x ||
        a.x > b.x + b.width ||
        a.y + a.height < b.y ||
        a.y > b.y + b.height
      );
    }

    init();
  </script>
</body>
</html>

