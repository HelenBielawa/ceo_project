<script>
    export let width;
    export let yScale;
    export let xScale;
  
    let yTicks = [0, 2, 4, 5, 6, 8, 10];
  </script>
  
   <g class='axis y'>
    {#each yTicks as tick, index}
      <g class='tick' transform="translate(0, {yScale(tick)})">
        <line x1={0} x2={width*2} y1={0} y2={0} stroke={tick == 5 ? 'black' : 'grey'} /> <!-- ✅ -->
        <text x={xScale(5)}>{tick}</text>
      </g>
    {/each}
  </g>

 