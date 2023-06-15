<script>
    export let height;
    export let width;
    export let xScale;
    export let yScale;
   
    let xTicks = [0, 2, 4, 5, 6, 8, 10];
  </script>
  
  <g class="axis" transform="translate(0, {height})">
    {#each xTicks as tick, index}
      <g class='tick' transform="translate({xScale(tick)}, 0)">
        <line x1={0}
        x2={0}
        y1={-yScale(0)}
        y2={6}
        stroke={tick == 5 ? "black" : "transparent"}
        stroke-width={tick === 5 ? "2px" : "1px"}/>
        <text y={-yScale(5)} dy={9}
        text-anchor={tick === 0 ? "start" : index === 10 ? "end" : "middle"}
        dominant-baseline="middle">{tick === 5 ? "" : tick}</text>
      </g>
    {/each}
    <text class="axis-title" 
          y={-yScale(5)} 
          x={width} 
          text-anchor="end"
      >Right;</text
    >
    <text class="axis-title" 
    y={-yScale(5)} 
    x=0 
    text-anchor="left">
    Left</text
    >
  </g>


<style>
  .axis text{
  font-family: 'Montserrat', sans-serif;
  font-weight: 300;
  }
</style>
