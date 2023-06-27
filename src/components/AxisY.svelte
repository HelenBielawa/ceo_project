<script>
    export let width;
    export let yScale;
    export let xScale;
  
    let yTicks = [0, 20, 40, 50, 60, 80, 100];
  </script>
  
   <g class="axis">
    {#each yTicks as tick, index}
      <g class='tick' transform="translate(0, {yScale(tick)})">
        <line x1={0} x2={width*2} y1={0} y2={0}
        stroke={tick == 50 ? 'black' : 'transparent'}
        stroke-width={tick === 50 ? "2px" : "1px"}/> 
        <text x={xScale(50)}
        dy={tick === 100 ? 15 : 0}
        ></text>
      </g>
    {/each}

  <text
    y={yScale(100)} 
    x={xScale(50)} 
    text-anchor="end"
    dy=15>Pro Independence 
  </text>
<text
  y={yScale(0)} 
  x={xScale(50)}
  text-anchor="end"
  dy=-15>
  Pro Spain
  </text>
</g>

<style>
  .axis text{
  font-family: 'Montserrat', sans-serif;
  font-weight: 400;
  }

  .arrow {
    border: solid black;
    border-width: 0 3px 3px 0;
    display: inline-block;
    padding: 3px;
  }

  .right {
    transform: rotate(-45deg);
    -webkit-transform: rotate(-45deg);
  }

  .left {
    transform: rotate(135deg);
    -webkit-transform: rotate(135deg);
  }

  .up {
    transform: rotate(-135deg);
    -webkit-transform: rotate(-135deg);
  }

  .down {
    transform: rotate(45deg);
    -webkit-transform: rotate(45deg);
  } 
</style>
