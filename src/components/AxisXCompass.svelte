<script>
    export let height;
    export let width;
    export let xScale;
    export let yScale;
  
    let xTicks = [0, 20, 40, 50, 60, 80, 100];
  </script>
  
  <g class="axis" transform="translate(0, {height})">
    <!-- Compass circle -->
    <circle cx={width / 2} cy={-yScale(50)} r={yScale(50)} class="circle" />
  
  <!-- X-axis line -->
  <line x1={0} x2={width} y1={yScale(50)} y2={yScale(50)} class="axis-line" />

  <!-- Y-axis line -->
  <line x1={0} x2={0} y1={0} y2={-height} class="axis-line" />
   

  </g>
      <!-- Axis labels 
      <text class="axis-title" y={yScale(100) + 15} x={xScale(50)} text-anchor="middle">Pro Independence</text>
      <text class="axis-title" y={yScale(50)-3} x={xScale(100)} text-anchor="end">More Right</text>
      <text class="axis-title" y={yScale(50)-3} x={xScale(0)} text-anchor="left">More Left</text>
      <text class="axis-title" y={yScale(0) - 15} x={xScale(50)} text-anchor="middle">Pro Spain</text>
  -->
  <style>
    .axis text {
      font-family: 'Montserrat', sans-serif;
      font-weight: 300;
    }
  
    .circle {
      fill: none;
      stroke: black;
      stroke-width: 1px;
    }
  
    .needle {
      stroke: black;
      stroke-width: 2px;
    }
  
    .tick line {
      stroke: black;
      stroke-width: 1px;
    }
  
    .axis-title {
      font-size: 12px;
    }
  </style>
  