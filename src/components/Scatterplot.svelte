<script>
    import AxisX from "./AxisX.svelte";
    import AxisY from "./AxisY.svelte";
    import Tooltip from "./Tooltip.svelte";
    import sociodemData from "../data/testIndividuals.json";
    import stepContent from "../data/stepContent.json";
    import politicalData from "../data/politicalClusters.json";
    import groupData from "../data/testData_group1.json";
    import { fly } from "svelte/transition";
    import { scaleLinear } from "d3-scale";

    export let currentStep;

    let individualsData = sociodemData.map(d => ({"RIGHT_PRED": d["RIGHT.PRED"],
                                "INDEP_PRED": d["INDEP.PRED"],
                                "NUM": 1
                                      }));

    $: currentStepContent = stepContent[currentStep];

    $: console.log("in the Plot, currStep: ", currentStep);
    $: console.log("content: ", currentStepContent)
    
    $: width = 600;
    $: height = 800;

    $: data = politicalData.map(d => ({"RIGHT_PRED": d.RIGHT_Pred_Mean,
                                "INDEP_PRED": d.INDEP_Pred_Mean,
                                "NUM": d.Num_Users}));
    $: grdata  = [];




    const margin = { top:0, right: 0, bottom: 0, left: 0 };
    const radius = 0.02;
  
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
    let currentStatus = "politicalViz";

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
        data = individualsData.map(d => ({"RIGHT_PRED": d["RIGHT.PRED"],
                                "INDEP_PRED": d["INDEP.PRED"],
                                "NUM": 1
                                      }))
      }

    }

    function getTransitionParams(d){

      let destinationX = xScale(d.RIGHT_Pred_Mean);
      let destinationY = yScale(d.INDEP_Pred_Mean);

      let originX = xScale(individualsData.filter(item => individualsData.indexOf(item) == d.Cluster)[0].RIGHT_PRED * 10);
      let originY = yScale(individualsData.filter(item => individualsData.indexOf(item) == d.Cluster)[0].INDEP_PRED * 10);

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
          {#each data.sort((a, b) => a.RIGHT_PRED - b.RIGHT_PRED) as d, index}
            <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
            <circle 
              transition:fly={currentStatus == "groupViz" ? { x: -100, opacity: 50, duration: 500 }
                      : {...getTransitionParams(d)}}
              cx={xScale(d.RIGHT_PRED * 10)}
              cy={yScale(d.INDEP_PRED * 10)}
              fill="black"
              stroke="black"
              r={hoveredData == d ? radius * d.NUM * 1.5 : radius * d.NUM * 1.5}
              opacity={hoveredData ? (hoveredData == d ? 1 : 0.45) : currentStatus == "groupViz" ? 0.2 : 0.6}
              on:mouseover={() => currentStatus === "sociodemViz"? hoveredData = sociodemData[index]
                            : hoveredData = politicalData[index]}
              on:focus={() => hoveredData = d}
              on:click={() => handleCircleClick(individualsData.indexOf(d))}
              on:keydown={(event) => {
                if (event.key === 'Enter') {
                  handleCircleClick(individualsData.indexOf(d));
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
              fill="black"
              stroke="none"
              r = 5
              opacity = 1
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
  

   .chart-container{
   position: inherit;
    display: flex;
    flex-wrap: wrap;
    white-space: nowrap;
    width: 100%;
    height: 100%;
    z-index: 100;
    background: none;
    pointer-events: none;
   }
    circle {
      /*transition: r 300ms ease, opacity 500ms ease;*/
      cursor: pointer;
      pointer-events: all;
    }
  </style>
  