import{r as s}from"./request-C4XSmzhs.js";function t(r=1){return s.get("/courses",{params:{majorId:r}})}function u(r,e){return s.post(`/courses/${r}/progress`,{progress:e})}export{t as g,u};
