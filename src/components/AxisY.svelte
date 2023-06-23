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
        dy={tick === 100 ? 15 : 0}>{tick === 50 ? "" : tick+"%"}</text>
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
  Contra Independence
</text>
</g>

<style>
  .axis text{
  font-family: 'Montserrat', sans-serif;
  font-weight: 300;
  }
</style>
