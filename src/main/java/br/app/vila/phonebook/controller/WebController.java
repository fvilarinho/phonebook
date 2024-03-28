package br.app.vila.phonebook.controller;

import br.app.vila.phonebook.controller.model.ActionModel;
import br.app.vila.phonebook.model.Phone;
import br.app.vila.phonebook.service.PhoneService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class WebController {
    private final PhoneService phoneService;

    @Autowired
    public WebController(PhoneService phoneService) {
        this.phoneService = phoneService;
    }

    @GetMapping("/ui")
    public String home(Model model) {
        model.addAttribute("search", new Phone());
        model.addAttribute("action", new ActionModel());
        model.addAttribute("entries", phoneService.findAll());

        return "home";
    }

    @PostMapping("/ui/search")
    public String search(Model model, @ModelAttribute("search") Phone search) {
        model.addAttribute("action", new ActionModel());
        model.addAttribute("entries", phoneService.findAllByName(search.getName()));

        return "home";
    }

    @GetMapping("/ui/add")
    public String add(Model model) {
        model.addAttribute("action", new ActionModel());
        model.addAttribute("entry", new Phone());

        return "input";
    }

    @GetMapping("/ui/edit/{id}")
    public String edit(Model model, @NonNull @PathVariable Long id) {
        model.addAttribute("action", new ActionModel());
        model.addAttribute("entry", phoneService.findById(id));

        return "input";
    }

    @GetMapping("/ui/delete/{id}")
    public String delete(Model model, @NonNull @PathVariable Long id) {
        phoneService.deleteById(id);

        model.addAttribute("search", new Phone());
        model.addAttribute("action", new ActionModel(true, "The entry was deleted successfully!"));
        model.addAttribute("entries", phoneService.findAll());

        return "home";
    }

    @PostMapping("/ui/save")
    public String save(Model model, @NonNull Phone phone, @ModelAttribute("search") Phone search) {
        phoneService.save(phone);

        model.addAttribute("search", new Phone());
        model.addAttribute("action", new ActionModel(true, "The entry was saved successfully!"));
        model.addAttribute("entries", phoneService.findAll());

        return "home";
    }
}