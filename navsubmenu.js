$(document).ready(function(){
  $('.dropdown-submenu a.submenu').on("click", function(e){
    $(this).next('ul').toggle();
    e.stopPropagation();
    e.preventDefault();
  });

  $('.navLink').on("click", function(e){    
    $( this ).closest("li").closest("ul").toggle();
  });

   $('.dropdown').on("click", function(e){    
    $(this).find(".dropdown-submenu").find("ul").css("display","none");
  });
});