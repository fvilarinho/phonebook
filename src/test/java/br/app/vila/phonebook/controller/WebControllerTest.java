package br.app.vila.phonebook.controller;

import br.app.vila.phonebook.controller.constants.WebControllerAttributes;
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
                        .andExpect(model().attributeExists(WebControllerAttributes.SEARCH))
                        .andExpect(model().attributeExists(WebControllerAttributes.ACTION))
                        .andExpect(model().attributeExists(WebControllerAttributes.ENTRIES))
                        .andExpect(view().name("home"));
    }

    @Test
    void testSearch() throws Exception {
        when(phoneService.findAllByName("Doe")).thenReturn(List.of(
            new Phone(1L, "John Doe", "123456789")
        ));

        mockMvc.perform(post("/ui/search")
                        .flashAttr(WebControllerAttributes.SEARCH, new Phone(null, "Doe", null)))
                        .andExpect(status().isOk())
                        .andExpect(model().attributeExists(WebControllerAttributes.ACTION))
                        .andExpect(model().attributeExists(WebControllerAttributes.ENTRIES))
                        .andExpect(view().name("home"));

        verify(phoneService, times(1)).findAllByName("Doe");
    }

    @Test
    void testAdd() throws Exception {
        mockMvc.perform(get("/ui/add"))
                        .andExpect(status().isOk())
                        .andExpect(model().attributeExists(WebControllerAttributes.SEARCH))
                        .andExpect(model().attributeExists(WebControllerAttributes.ACTION))
                        .andExpect(model().attributeExists(WebControllerAttributes.ENTRY))
                        .andExpect(view().name("input"));
    }

    @Test
    void testEdit() throws Exception {
        when(phoneService.findById(1L)).thenReturn(Optional.of(new Phone(1L, "John Doe", "123456789")));

        mockMvc.perform(get("/ui/edit/1"))
                        .andExpect(status().isOk())
                        .andExpect(model().attributeExists(WebControllerAttributes.SEARCH))
                        .andExpect(model().attributeExists(WebControllerAttributes.ACTION))
                        .andExpect(model().attributeExists(WebControllerAttributes.ENTRY))
                        .andExpect(view().name("input"));

        verify(phoneService, times(1)).findById(1L);
    }

    @Test
    void testDelete() throws Exception {
        mockMvc.perform(get("/ui/delete/1"))
                        .andExpect(status().isOk())
                        .andExpect(model().attributeExists(WebControllerAttributes.SEARCH))
                        .andExpect(model().attributeExists(WebControllerAttributes.ACTION))
                        .andExpect(model().attributeExists(WebControllerAttributes.ENTRIES))
                        .andExpect(view().name("home"));

        verify(phoneService, times(1)).deleteById(1L);
    }

    @Test
    void testSave() throws Exception {
        Phone entry = new Phone(1L, "John Doe", "123456789");

        mockMvc.perform(post("/ui/save")
                        .flashAttr(WebControllerAttributes.ENTRY, entry))
                        .andExpect(status().isOk())
                        .andExpect(model().attributeExists(WebControllerAttributes.SEARCH))
                        .andExpect(model().attributeExists(WebControllerAttributes.ACTION))
                        .andExpect(model().attributeExists(WebControllerAttributes.ENTRIES))
                        .andExpect(view().name("home"));

        verify(phoneService, times(1)).save(entry);

        entry = new Phone("John Doe", "123456789");

        mockMvc.perform(post("/ui/save")
                        .flashAttr(WebControllerAttributes.ENTRY, entry))
                .andExpect(status().isOk())
                .andExpect(model().attributeExists(WebControllerAttributes.SEARCH))
                .andExpect(model().attributeExists(WebControllerAttributes.ACTION))
                .andExpect(model().attributeExists(WebControllerAttributes.ENTRIES))
                .andExpect(view().name("home"));

        verify(phoneService, times(1)).save(entry);
    }
}