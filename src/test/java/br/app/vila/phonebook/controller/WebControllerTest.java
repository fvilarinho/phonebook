package br.app.vila.phonebook.controller;

import br.app.vila.phonebook.controller.constants.WebControllerConstants;
import br.app.vila.phonebook.model.Phone;
import br.app.vila.phonebook.service.PhoneService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Optional;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(WebController.class)
class WebControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private PhoneService phoneService;

    @Test
    void testHome() throws Exception {
        mockMvc.perform(get("/ui"))
               .andExpect(status().isOk())
               .andExpect(model().attributeExists(WebControllerConstants.SEARCH_ATTRIBUTE_ID))
               .andExpect(model().attributeExists(WebControllerConstants.ACTION_ATTRIBUTE_ID))
               .andExpect(model().attributeExists(WebControllerConstants.ENTRIES_ATTRIBUTE_ID))
               .andExpect(view().name("home"));
    }

    @Test
    void testSearch() throws Exception {
        when(phoneService.findAllByName("Doe")).thenReturn(List.of(
            new Phone(1L, "John Doe", "123456789")
        ));

        mockMvc.perform(post("/ui/search")
               .flashAttr(WebControllerConstants.SEARCH_ATTRIBUTE_ID, new Phone(null, "Doe", null)))
               .andExpect(status().isOk())
               .andExpect(model().attributeExists(WebControllerConstants.ACTION_ATTRIBUTE_ID))
               .andExpect(model().attributeExists(WebControllerConstants.ENTRIES_ATTRIBUTE_ID))
               .andExpect(view().name("home"));

        verify(phoneService, times(1)).findAllByName("Doe");
    }

    @Test
    void testAdd() throws Exception {
        mockMvc.perform(get("/ui/add"))
               .andExpect(status().isOk())
               .andExpect(model().attributeExists(WebControllerConstants.ACTION_ATTRIBUTE_ID))
               .andExpect(model().attributeExists(WebControllerConstants.ENTRY_ATTRIBUTE_ID))
               .andExpect(view().name("input"));
    }

    @Test
    void testEdit() throws Exception {
        when(phoneService.findById(1L)).thenReturn(Optional.of(new Phone(1L, "John Doe", "123456789")));

        mockMvc.perform(get("/ui/edit/1"))
               .andExpect(status().isOk())
               .andExpect(model().attributeExists(WebControllerConstants.ACTION_ATTRIBUTE_ID))
               .andExpect(model().attributeExists(WebControllerConstants.ENTRY_ATTRIBUTE_ID))
               .andExpect(view().name("input"));

        verify(phoneService, times(1)).findById(1L);
    }

    @Test
    void testDelete() throws Exception {
        mockMvc.perform(get("/ui/delete/1"))
               .andExpect(status().isOk())
               .andExpect(model().attributeExists(WebControllerConstants.SEARCH_ATTRIBUTE_ID))
               .andExpect(model().attributeExists(WebControllerConstants.ACTION_ATTRIBUTE_ID))
               .andExpect(model().attributeExists(WebControllerConstants.ENTRIES_ATTRIBUTE_ID))
               .andExpect(view().name("home"));

        verify(phoneService, times(1)).deleteById(1L);
        verify(phoneService, times(1)).findAll();
    }

    @Test
    void testSave() throws Exception {
        Phone phone = new Phone(1L, "John Doe", "123456789");

        mockMvc.perform(post("/ui/save")
                        .flashAttr("phone", phone))
               .andExpect(status().isOk())
               .andExpect(model().attributeExists(WebControllerConstants.SEARCH_ATTRIBUTE_ID))
               .andExpect(model().attributeExists(WebControllerConstants.ACTION_ATTRIBUTE_ID))
               .andExpect(model().attributeExists(WebControllerConstants.ENTRIES_ATTRIBUTE_ID))
               .andExpect(view().name("home"));

        verify(phoneService, times(1)).save(phone);
        verify(phoneService, times(1)).findAll();
    }
}