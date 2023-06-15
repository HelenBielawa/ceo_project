<script>
    export let data;
    export let xScale;
    export let yScale;
    export let width;
    export let currentStatus;
    import { fly } from "svelte/transition";
 
    $: x = xScale(data.RIGHT_Pred_Mean);
    $: y = yScale(data.INDEP_Pred_Mean * 10);
  
    let tooltipWidth;
  
    const xNudge = 15;
    const yNudge = 30;
  
    $: xPosition =
      x + tooltipWidth > width ? x - tooltipWidth - xNudge : x + xNudge;
    $: yPosition = y + yNudge;

    </script>
  
  <div
    class="tooltip"
    transition:fly={{ y: 10 }}
    style="position: absolute; top: {yPosition}px; left: {xPosition}px"
    bind:clientWidth={tooltipWidth}
  >
    {#if currentStatus == "groupViz"}
      Click on the circle to get back to the main chart.
    {/if}
    {#if currentStatus == "generalViz"}
      <h1>About this group:</h1>
      <p>
      province: {data.PROVINCE}<br>
      municipality: {data.MUNICIPALITY}<br>
      language: {data.LANGUAGE}<br>
      age range: {data.AGE_RANGE}<br>
      Click to see all {data.Num_Users} members</p>
    {/if}

  </div>
  
  <style>
    .tooltip {
      padding: 8px 6px;
      background: white;
      box-shadow: rgba(0, 0, 0, 0.15) 2px 3px 8px;
      border-radius: 3px;
      pointer-events: none;
      transition: top 300ms ease, left 300ms ease;
      max-width: 60%;
      max-height: 30%;
      overflow: auto;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
      transition: transform 0.3s ease;
      background-image: linear-gradient(to bottom right, #ffffff, #eaeaea);
      border-radius: 8px;
    }
   
    h1 {
      font-size: 1rem;
      font-weight: 400;
      margin-bottom: 6px;
      width: 100%;
    }
  
    p{
      text-align: left;
    }
  </style>
  