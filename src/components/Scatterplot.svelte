<script>
    import AxisX from "./AxisX.svelte";
    import AxisY from "./AxisY.svelte";
    import Tooltip from "./Tooltip.svelte";
    import generalData from "../data/testData_mainPlot.json";
    import groupData from "../data/testData_group1.json";
    import { fly } from "svelte/transition";
    import { onMount } from "svelte";
    import { scaleLinear } from "d3-scale";
    
    $: width = 600;
    $: height = 800;

    $: data = generalData;
    $: grdata  = [];
  
    const margin = { top:0, right: 0, bottom: 0, left: 0 };
    const radius = 10;
  
    $: innerWidth = width - margin.left - margin.right;
    $: innerHeight = height - margin.top - margin.bottom;
  
    $: xScale = scaleLinear()
      .domain([0, 10])
      .range([0, innerWidth]);
  
    $: yScale = scaleLinear()
      .domain([0, 10])
      .range([innerHeight, 0]);
  
    let hoveredData;
    let clickedGroup;
    let currentStatus = "generalViz";

    const loadGroupJSON = (groupID) => {
    const url = "./src/data/testData_group"+ groupID + ".json";
    return fetch(url)
      .then(response => response.json())
      .catch(error => console.error(error));
    };

    function handleCircleClick(groupID) {
      if (currentStatus == "generalViz"){
        currentStatus = "groupViz";
        console.log("click "+groupID)
        grdata = groupData.filter(d => d.groupID === groupID);
        console.log(grdata);
      }
      else{
        currentStatus = "generalViz";
        data = generalData;
      }

    }

    function getTransitionParams(d){

      let destinationX = xScale(d.rightness);
      let destinationY = yScale(d.independence);

      let originX = xScale(generalData.filter(item => item.groupID == d.groupID)[0].rightness);
      let originY = yScale(generalData.filter(item => item.groupID == d.groupID)[0].independence);

      const deltaX = -destinationX + originX;
      const deltaY = -destinationY + originY;

      return {
        x: deltaX,
        y: deltaY,
        duration: 1000
      };
    }

  </script>

  <div
    class="chart-container"
    bind:clientWidth={width}
    bind:clientHeight={height}
  >
    <svg {width} {height}
    on:mouseleave={() => hoveredData = null}>

      <g class="inner-chart" transform="translate({margin.left}, {margin.top})">
          <AxisY width={innerWidth} {yScale} {xScale} {height}/>
          <AxisX height={innerHeight} width={innerWidth} {xScale} {yScale} />
          {#each data.sort((a, b) => a.rightness - b.rightness) as d, index}
            <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
            <circle 
              transition:fly={currentStatus == "groupViz" ? { x: -100, opacity: 50, duration: 500 }
                      : {...getTransitionParams(d)}}
              cx={xScale(d.rightness)}
              cy={yScale(d.independence)}
              fill="black"
              stroke="black"
              r={hoveredData == d ? radius * 1.5 : radius}
              opacity={hoveredData ? (hoveredData == d ? 1 : 0.45) : d.diversity * 0.1}
              on:mouseover={() => hoveredData = d}
              on:focus={() => hoveredData = d}
              on:click={() => handleCircleClick(d.groupID)}
              on:keydown={(event) => {
                if (event.key === 'Enter') {
                  handleCircleClick(d.groupID);
                }
              }}
              tabindex="0"
            />
          {/each}
        {#if currentStatus === "groupViz"}
          {#each grdata as d, index}
            <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
            <circle 
              in:fly={{...getTransitionParams(d)}}
              cx={xScale(d.rightness)}
              cy={yScale(d.independence)}
              fill="red"
              stroke="none"
              r = 5
              opacity = 0.5
            />
          {/each}
        {/if}
      </g>
    </svg>
    {#if hoveredData}
      <Tooltip {xScale} {yScale} {width} data={hoveredData} {currentStatus} />
    {/if}
  </div>
  
  <style>
    :global(.tick text, .axis-title) {
      font-weight: 400; /* How thick our text is */
      font-size: 12px; /* How big our text is */
      fill: hsla(212, 10%, 53%, 1); /* The color of our text */
    }
  
    .chart-container {
      width: 100%;
      height: 100vh;
      position: fixed;
      top: 0;
      left: 0;
      bottom: 0;
      right: 0;
   }


    circle {
      /*transition: r 300ms ease, opacity 500ms ease;*/
      cursor: pointer;
    }
  
    h1 {
      margin: 0 0 0.5rem 0;
      font-size: 1.35rem;
      font-weight: 600;
    }
  </style>
  