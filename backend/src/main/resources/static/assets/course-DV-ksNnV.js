import{r as s}from"./request-Dm961Y1F.js";function t(r=1){return s.get("/courses",{params:{majorId:r}})}function u(r,e){return s.post(`/courses/${r}/progress`,{progress:e})}export{t as g,u};
