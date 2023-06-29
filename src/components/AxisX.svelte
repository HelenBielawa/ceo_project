<script>
    export let height;
    export let width;
    export let xScale;
    export let yScale;
   
    let xTicks = [0, 20, 40, 50, 60, 80, 100];
  </script>
  
  <g class="axis" transform="translate(0, {height})">

    {#each xTicks as tick, index}
      <g class='tick' transform="translate({xScale(tick)}, 0)">

        <line x1={0}
        x2={0}
        y1={-yScale(0)}
        y2={6}
        stroke={tick == 50 ? "black" : "transparent"}
        stroke-width={tick === 50 ? "2px" : "1px"}
        />
        <text y={-yScale(50)} dy={9}
        text-anchor={tick === 0 ? "start" : index === 100 ? "end" : "middle"}
        dominant-baseline="middle"></text>
      </g>
    {/each}
    <text class="axis-title" 
          y={-yScale(50)-3} 
          x={width} 
          text-anchor="end"
      >Right </text
    >
    <text class="axis-title" 
    y={-yScale(50)-3} 
    x=0 
    text-anchor="left">
    Left</text
    >
  </g>


<style>
  .axis{
    z-index: 0;
  }
  .axis text{
  font-family: 'Montserrat', sans-serif;
  font-weight: 400;
  }

  .arrow {
    fill: black;
  }

  .arrow.left {
    transform: rotate(180deg);
  }

  .arrow.right {
    transform: rotate(0deg);
  }

</style>
