package br.app.vila.phonebook.controller;

import br.app.vila.phonebook.controller.constants.WebControllerAttributes;
import br.app.vila.phonebook.controller.model.ActionModel;
import br.app.vila.phonebook.model.Phone;
import br.app.vila.phonebook.service.PhoneService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

import java.util.Optional;

@Controller
public class WebController {
    private static final Logger logger = LoggerFactory.getLogger(WebController.class);

    private final PhoneService phoneService;

    @Autowired
    public WebController(PhoneService phoneService) {
        this.phoneService = phoneService;
    }

    @GetMapping("/ui")
    public String home(Model model) {
        logger.info("Loading all entries registered in the phonebook");

        model.addAttribute(WebControllerAttributes.SEARCH, new Phone());
        model.addAttribute(WebControllerAttributes.ACTION, new ActionModel());
        model.addAttribute(WebControllerAttributes.ENTRIES, phoneService.findAll());

        return "home";
    }

    @PostMapping("/ui/search")
    public String search(Model model, @ModelAttribute(WebControllerAttributes.SEARCH) Phone search) {
        logger.info("Searching for entries in the phonebook");

        model.addAttribute(WebControllerAttributes.ACTION, new ActionModel());
        model.addAttribute(WebControllerAttributes.ENTRIES, phoneService.findAllByName(search.getName()));

        return "home";
    }

    @GetMapping("/ui/add")
    public String add(Model model) {
        logger.info("Adding a new entry in phonebook");

        model.addAttribute(WebControllerAttributes.SEARCH, new Phone());
        model.addAttribute(WebControllerAttributes.ACTION, new ActionModel());
        model.addAttribute(WebControllerAttributes.ENTRY, new Phone());

        return "input";
    }

    @GetMapping("/ui/edit/{id}")
    public String edit(Model model, @NonNull @PathVariable Long id) {
        Optional<Phone> item;

        try {
            item = phoneService.findById(id);

            if (item.isEmpty()) {
                logger.warn("Entry with id {} does not exist!", id);

                return "home";
            }
        }
        catch(Throwable e){
            logger.error(e.getMessage());

            return "home";
        }

        logger.info("Editing the entry with id {}", id);

        model.addAttribute(WebControllerAttributes.SEARCH, new Phone());
        model.addAttribute(WebControllerAttributes.ACTION, new ActionModel());
        model.addAttribute(WebControllerAttributes.ENTRY, item);

        return "input";
    }

    @GetMapping("/ui/delete/{id}")
    public String delete(Model model, @NonNull @PathVariable Long id) {
        Optional<Phone> item;

        try {
            item = phoneService.findById(id);

            if (item.isEmpty()) {
                logger.warn("Entry with id {} does not exist!", id);

                return "home";
            }
        }
        catch(Throwable e){
            logger.error(e.getMessage());

            return "home";
        }

        phoneService.deleteById(id);

        logger.info("Deleting the entry with id {}", id);

        model.addAttribute(WebControllerAttributes.SEARCH, new Phone());
        model.addAttribute(WebControllerAttributes.ACTION, new ActionModel(true, "The entry was deleted successfully!"));
        model.addAttribute(WebControllerAttributes.ENTRIES, phoneService.findAll());

        return "home";
    }

    @PostMapping("/ui/save")
    public String save(Model model, @ModelAttribute(WebControllerAttributes.ENTRY) Phone entry) {
        boolean isNew = (entry.getId() == null);

        phoneService.save(entry);

        if(isNew)
            logger.info("Saving the new entry with id '{}'", entry.getId());
        else
            logger.info("Updating the entry with id {}", entry.getId());

        model.addAttribute(WebControllerAttributes.SEARCH, new Phone());
        model.addAttribute(WebControllerAttributes.ACTION, new ActionModel(true, "The entry was saved successfully!"));
        model.addAttribute(WebControllerAttributes.ENTRIES, phoneService.findAll());

        return "home";
    }
}